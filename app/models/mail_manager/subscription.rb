=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Subscription ties Contacts to MailingLists and keeps track of subscription preferences or 'status'

Statuses:
'active' - user has an active subscription to list
'pending' - awaiting user approval through email
'unsubscribed' - user or admin has unsubscribe user from list 
'failed_address' - BounceJob has detected a 'permanently' fatal email failure - like the account or domain doesn't exist 

FIXME: currently tied to users table
=end

module MailManager
  class Subscription < ActiveRecord::Base
    self.table_name =  "#{MailManager.table_prefix}subscriptions"
    belongs_to :contact, :class_name => 'MailManager::Contact'
    belongs_to :mailing_list, :class_name => 'MailManager::MailingList'
    has_many :messages, :class_name => 'MailManager::Message'

    validates_presence_of :mailing_list_id
    validates_associated :mailing_list

    scope :active, :conditions => {:status => 'active'}, 
                         :joins => "INNER JOIN #{MailManager.table_prefix}contacts ON 
                            #{MailManager.table_prefix}subscriptions.contact_id = #{MailManager.table_prefix}contacts.id 
                            and #{MailManager.table_prefix}contacts.deleted_at IS NULL"

    scope :unsubscribed, :conditions => {:status => 'unsubscribed'}, 
                         :joins => "INNER JOIN #{MailManager.table_prefix}contacts ON 
                            #{MailManager.table_prefix}subscriptions.contact_id = #{MailManager.table_prefix}contacts.id 
                            and #{MailManager.table_prefix}contacts.deleted_at IS NULL"

    scope :failed_address, :conditions => {:status => 'failed_address'}, 
                         :joins => "INNER JOIN #{MailManager.table_prefix}contacts ON 
                            #{MailManager.table_prefix}subscriptions.contact_id = #{MailManager.table_prefix}contacts.id 
                            and #{MailManager.table_prefix}contacts.deleted_at IS NULL"

    scope :pending, :conditions => {:status => 'pending'}, 
                         :joins => "INNER JOIN #{MailManager.table_prefix}contacts ON 
                            #{MailManager.table_prefix}subscriptions.contact_id = #{MailManager.table_prefix}contacts.id 
                            and #{MailManager.table_prefix}contacts.deleted_at IS NULL" 

    include StatusHistory  
    override_statuses(['active','unsubscribed','failed_address','pending','duplicate','admin_unsubscribed'],'pending')
    before_create :set_default_status

    attr_protected :id
    
    #acts_as_audited rescue Rails.logger.warn "Audit Table not defined!"
    #

    def self.unsubscribed_emails_hash
      results = self.connection.execute(%Q|select distinct c.email_address 
        from #{MailManager.table_prefix}contacts c 
        inner join #{MailManager.table_prefix}subscriptions s on c.id=s.contact_id 
        where s.status in ('unsubscribed')|
      )
      results = results.map(&:values) if results.first.is_a?(Hash)
      results.inject(Hash.new){|h,r|h.merge!(r[0].to_s.strip.downcase => true)}
    end
  
    def contact_full_name
       contact.full_name
    end
 
    # changes or creates a subscription for the given contact and list and assigns the given status
    def self.change_subscription_status(contact, mailing_list, status)
      subscription = self.find_by_contact_id_and_mailing_list_id(contact.id, mailing_list.id)
      return subscription.change_status(status) if subscription
      subscription = Subscription.new
      subscription.contact = contact
      subscription.mailing_list = mailing_list
      subscription.change_status(status)
      subscription
    end

    # subscribes the contact to the list
    def self.subscribe(contact, mailing_list, status='active')
      change_subscription_status(contact, mailing_list, status)
    end

    # unsubscribes the contact from the list
    def self.unsubscribe(contact, mailing_list)
      change_subscription_status(contact, mailing_list, 'unsubscribed')
    end
  
    def mailing_list_name
      mailing_list.try(:name)
    end
    
    def active?
      status.eql?('active')
    end

    def pending?
      status.eql?('pending')
    end

    # unsubscribes a contact from all lists by looking them up through a messages GUID
    # FIXME: when we add more lists and the ability to have multiple subscriptions, this should 
    # remove only the list that is tied in the GUID and they should be linked to their options
    def self.unsubscribe_by_message_guid(guid)
      message = Message.find_by_guid(guid)
      contact = message.contact
      if message
        begin
          unsubscribed_subscriptions = self.unsubscribe_by_email_address(message.contact.email_address, message)
          return unsubscribed_subscriptions
        rescue => e
          Rails.logger.warn "Error Unsubscribing email: #{message.contact.email_address}\n#{e.message}\n #{e.backtrace.join("\n ")}"
          raise "An error occured."
        end
      else
        raise "Could not find your subscription!"
      end
      nil
    end
  
    def self.fail_by_email_address(email_address)
      Contact.find_all_by_email_address(email_address).each do |contact|
        contact.active_subscriptions.each do |subscription|
          subscription.change_status(:failed_address)
        end
      end
    end
    
    def self.unsubscribe_by_email_address(email_address,message=nil)
      subscriptions = []
      Contact.find_all_by_email_address(email_address).each do |contact|
        subscriptions += contact.active_subscriptions.each do |subscription|
          subscription.change_status(:unsubscribed)
        end
      end
      Mailer.delay.unsubscribed(subscriptions,email_address,
        subscriptions.first.contact, message) if \
        subscriptions.present?
      subscriptions
    end
  end
end


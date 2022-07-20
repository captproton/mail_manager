module MailManager
  class MailingsController < ::MailManager::ApplicationController
    before_filter :find_mailing, :except => [:new,:create,:index]
    before_filter :find_all_mailing_lists, :only => [:new,:create,:edit,:update]
    before_filter :find_mailables, :only => [:new,:create,:edit,:update]
    before_filter :get_mailables_for_select, :only => [:new,:create,:edit,:update]

    include DeleteableActions

    def index
      @mailings = Mailing.order("created_at desc").paginate(page: (params[:page] || 1),
        per_page: (params[:per_page] || 10))
    end

    def show
    end

    def new
      @mailing = Mailing.new
      @mailing.from_email_address = MailManager.default_from_email_address if MailManager.default_from_email_address
      @mailing.scheduled_at = Time.now
      @mailing.include_images = true
      @mailing.mailing_lists = @all_mailing_lists
    end

    def edit
    end
  
    def test
    end
  
    def schedule
      if @mailing.can_schedule? 
        @mailing.schedule
        flash[:info] = "Mailing scheduled."
      else
        flash[:warning] = ""
        if @mailing.scheduled_at.nil?
          flash[:warning] += "Error! You must edit your mailing and set a time for your mailing to run.<br/>"
        end
        if @mailing.status != 'pending'
          flash[:warning] += "Error! Your mailing must be pending in order to schedule it."
        end
      end
      redirect_to mail_manager.mailings_path
    end
  
    def cancel
      @mailing.cancel
      flash[:notice] = "Mailing cancelled."
      redirect_to mail_manager.mailings_path
    end
  
    def send_test
      @mailing.send_test_message(params[:test_email_addresses])
      flash[:notice] = "Test messages sent to #{params[:test_email_addresses]}."
      redirect_to mail_manager.mailings_path
    end

    def create
      @mailing = Mailing.new(params[:mailing])
      if @mailing.save
        flash[:notice] = 'Mailing was successfully created.'
        redirect_to(mail_manager.mailings_path)
      else
        render :action => "new"
      end
    end

    def update
      if @mailing.update_attributes(params[:mailing])
        @mailing.cancel
        flash[:notice] = 'Mailing was successfully updated and set to pending.  Be sure to reschedule your mailing.'        
        redirect_to(mail_manager.mailings_path)
      else
        render :action => "edit"
      end
    end

    protected
  
    def find_mailing
      @mailing = Mailing.find(params[:id])
    end
  
    def find_all_mailing_lists
      @all_mailing_lists = MailingList.active.find(:all, :order => "name asc")
    end
  
    def find_mailables
      @mailables = MailableRegistry.find
    end
  
    def get_mailables_for_select
      @mailables_for_select = @mailables.sort{|a,b| b.created_at <=> a.created_at}.
        collect{|mailable| 
        [mailable.name,"#{mailable.class.name}_#{mailable.id}"]}
    end
  end
end

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe MailManager::ContactsController, :type => :controller do
  render_views
  routes {MailManager::Engine.routes}

  # This should return the minimal set of attributes required to create a valid
  # MailManager::Contact. As you add validations to MailManager::Contact, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    FactoryGirl.attributes_for(:contact)
  }

  let(:invalid_attributes) {
    FactoryGirl.attributes_for(:contact, email_address: nil)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MailManager::ContactsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all contacts as @contacts" do
      contact = MailManager::Contact.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:contacts)).to eq([contact])
      expect(response.body).to have_content 'Listing Contacts'
    end
    it "assigns all mailing lists as @mailing_lists" do
      mailing_list = FactoryGirl.create(:mailing_list)
      get :index, {}, valid_session
      expect(assigns(:mailing_lists)).to eq([[mailing_list.name,mailing_list.id]])
      expect(response.body).to have_content 'Listing Contacts'
    end
    it "assigns all statuses as @statuses" do
      get :index, {}, valid_session
      expect(assigns(:statuses)).to eq([['Any',''],['Active','active'],
        ['Unsubscribed','unsubscribed'],['Failed Address','failed_address'],
        ['Pending','pending']
      ])
      expect(response.body).to have_content 'Listing Contacts'
    end
  end

  describe "GET #show" do
    it "assigns the requested contact as @contact" do
      contact = MailManager::Contact.create! valid_attributes
      get :show, {:id => contact.to_param}, valid_session
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe "GET #new" do
    it "assigns a new contact as @contact" do
      get :new, {}, valid_session
      expect(assigns(:contact)).to be_a_new(MailManager::Contact)
      expect(response.body).to have_content 'New Contact'
    end
  end

  describe "GET #edit" do
    it "assigns the requested contact as @contact" do
      contact = MailManager::Contact.create! valid_attributes
      get :edit, {:id => contact.to_param}, valid_session
      expect(assigns(:contact)).to eq(contact)
      expect(response.body).to have_content "Edit Contact"
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new MailManager::Contact" do
        expect {
          post :create, {:contact => valid_attributes}, valid_session
        }.to change(MailManager::Contact, :count).by(1)
      end

      it "assigns a newly created contact as @contact" do
        post :create, {:contact => valid_attributes}, valid_session
        expect(assigns(:contact)).to be_a(MailManager::Contact)
        expect(assigns(:contact)).to be_persisted
      end

      it "redirects to the created contact" do
        post :create, {:contact => valid_attributes}, valid_session
        expect(response).to redirect_to(contacts_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved contact as @contact" do
        post :create, {:contact => invalid_attributes}, valid_session
        expect(assigns(:contact)).to be_a_new(MailManager::Contact)
      end

      it "re-renders the 'new' template" do
        post :create, {:contact => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        FactoryGirl.attributes_for(:contact)
      }

      it "updates the requested contact" do
        contact = MailManager::Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => new_attributes}, valid_session
        contact = MailManager::Contact.find(contact.id)
        expect(contact).to match_attributes(new_attributes)
      end

      it "assigns the requested contact as @contact" do
        contact = MailManager::Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => valid_attributes}, valid_session
        expect(assigns(:contact)).to eq(contact)
      end

      it "redirects to the contact" do
        contact = MailManager::Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => valid_attributes}, valid_session
        expect(response).to redirect_to(contacts_path)
      end
    end

    context "with invalid params" do
      it "assigns the contact as @contact" do
        contact = MailManager::Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => invalid_attributes}, valid_session
        expect(assigns(:contact)).to eq(contact)
      end

      it "re-renders the 'edit' template" do
        contact = MailManager::Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested contact" do
      contact = MailManager::Contact.create! valid_attributes
      expect {
        delete :destroy, {:id => contact.to_param}, valid_session
      }.to change(MailManager::Contact, :count).by(-1)
    end

    it "redirects to the contact list" do
      contact = MailManager::Contact.create! valid_attributes
      delete :destroy, {:id => contact.to_param}, valid_session
      expect(response).to redirect_to(contacts_url)
    end
  end

end

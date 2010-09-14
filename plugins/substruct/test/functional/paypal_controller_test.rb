require File.dirname(__FILE__) + '/../test_helper'

class PaypalControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    # Stub the acknowledge method to not call home and ask Paypal if it really sent that IPN.
    ActiveMerchant::Billing::Integrations::Paypal::Notification.any_instance.stubs(
      :acknowledge).returns(true)

    # Setup the mailer.
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @initial_mbox_length = ActionMailer::Base.deliveries.length
    
    setup_new_order
    setup_fake_params
    
    # Configure the Paypal store login.
    assert Preference.save_settings({"cc_login" => @fake_params[:business]})
  end
  
  # Test the controller receiving a good IPN notification.
  def test_ipn_receiving_good_data
    # Exercise
    post :ipn, @fake_params

    # Verify
    @order.reload
    
    # Ensure has same amount of items
    assert_equal 2, @order.items.count, @order.items.inspect
    
    # Assert the transaction id was saved.
    assert_equal @order.auth_transaction_id, @fake_params[:txn_id]
    # We should have received a mail about that.
    assert_equal(
      ActionMailer::Base.deliveries.length, 
      @initial_mbox_length + 1
    )
    # Test that the response was a success message.
    assert_equal(
      ActionMailer::Base.deliveries[0].subject, 
      "Thank you for your order! (##{@order.order_number})"
    )
    # Stub the complete? method to raise an exception and make the code that handles it be reached.
    ActiveMerchant::Billing::Integrations::Paypal::Notification.any_instance.stubs(
      :complete?).raises('An error!')
    
    # Assert a exception was raised.
    assert_raise(RuntimeError) {
      # Post the data again.
      post :ipn, @fake_params
    }
    
    # We should NOT have received a mail about that.
    assert_equal(
      ActionMailer::Base.deliveries.length, 
      @initial_mbox_length + 1
    )
  end


  # Test the controller receiving a bad IPN notification.
  def test_ipn_receiving_bad_data
    # Make paypal params fail
    @fake_params = @fake_params.merge({ :mc_gross => "2.00" })       
    # Exercise
    post :ipn, @fake_params
    
    # Verify
    @order.reload
    
    # Ensure has same amount of items
    assert_equal 2, @order.items.count, @order.items.inspect
    
    # Assert the transaction id was NOT saved.
    assert_equal @order.auth_transaction_id, ""

    # We should have received a mail about that.
    assert_equal ActionMailer::Base.deliveries.length, @initial_mbox_length + 1
    
    # Test that the response was a failure message.
    assert_equal ActionMailer::Base.deliveries[0].subject, "An order has failed on the site"
  end
  
  private
    def setup_new_order
      oli_small_stuff = OrderLineItem.for_product(items(:small_stuff))
      oli_towel = OrderLineItem.for_product(items(:towel))
      
      @order = Order.new
      @order.order_line_items << oli_small_stuff
      @order.order_line_items << oli_towel
      @order.tax = 0.0
      @order.created_on = 1.day.ago
      @order.shipping_address = order_addresses(:uncle_scrooge_address)
      @order.order_user = order_users(:uncle_scrooge)
      @order.billing_address = order_addresses(:uncle_scrooge_address)
      @order.shipped_on = "" 
      @order.order_shipping_type = order_shipping_types(:ups_ground)
      @order.promotion_id = 0
      @order.notes = '<p>Order completed.<br/><span class="info">[04-04-08 05:18 PM]</span></p>'
      @order.referer = "" 
      @order.shipping_cost = 11.0
      @order.order_number = Order.generate_order_number
      @order.order_account = order_accounts(:uncle_scrooge_account)
      @order.auth_transaction_id = "" 
      @order.order_status_code = order_status_codes(:cart)

      assert @order.save
      assert_equal 2, @order.items.count
    end
    
    def setup_fake_params
      # TODO: Take a look closely how these params are filled in the paypal guides.
      # Create a fake hash to be used as params and to generate the query string.
      @fake_params = {
        :address_city => "San Jose",
        :address_country => "United States",
        :address_country_code => "US",
        :address_name => "Test User",
        :address_state => "CA",
        :address_status => "confirmed",
        :address_street => "1 Main St",
        :address_zip => "95131",
        :business => "seller@my.own.store",
        :charset => "windows-1252",
        :custom => "",
        :first_name => "Test",
        :last_name => "User",
        :invoice => @order.order_number,
        :item_name1 => @order.order_line_items[0].name,
        :item_name2 => @order.order_line_items[1].name,
        :item_number1 => "",
        :item_number2 => "",
        :mc_currency => "USD",
        :mc_fee => "0.93",
        :mc_gross => @order.line_items_total + @order.shipping_cost,
        # Why the shipping cost is here?
        :mc_gross_1 => @order.order_line_items[0].total + @order.shipping_cost,
        :mc_gross_2 => @order.order_line_items[1].total,
        :mc_handling => "0.00",
        :mc_handling1 => "0.00",
        :mc_handling2 => "0.00",
        :mc_shipping => @order.shipping_cost,
        :mc_shipping1 => @order.shipping_cost,
        :mc_shipping2 => "0.00",
        :notify_version => "2.4",
        :num_cart_items => @order.order_line_items.length,
        :payer_email => "buyer@my.own.store",
        :payer_id => "3GQ2THTEB86ES",
        :payer_status => "verified",
        :payment_date => "08:41:36 May 28, 2008 PDT",
        :payment_fee => "0.93",
        :payment_gross => "21.75",
        :payment_status => "Completed",
        :payment_type => "instant",
        :quantity1 => @order.order_line_items[0].quantity,
        :quantity2 => @order.order_line_items[1].quantity,
        :receiver_email => "seller@my.own.store",
        :receiver_id => "TFLJN8N28W6VW",
        :residence_country => "US",
        :tax => "0.00",
        :tax1 => "0.00",
        :tax2 => "0.00",
        :test_ipn => "1",
        :txn_id => "53B76609FE637874A",
        :txn_type => "cart",
        :verify_sign => "AKYASk7fkoMqSjT.TB-8hzZ9riLTAVyg5ho1FZd9XrCkuXZCpp-Q6uEY",
        :memo => "A message."
      }
    end


end

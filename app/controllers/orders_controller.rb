class OrdersController < ApplicationController
  def index
    @orders = Order.paginate(per_page:20,page:params[:page]).includes([:sales])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.create!(order_params)
    redirect_to '/orders'
  end


  def edit
    @order = Order.find params[:id]
  end

  def destroy
    @order = Order.find params[:id]
    @order.destroy
    render js:"alert('已删除!');location.reload();"
  end

  def update
    @order = Order.find params[:id]
    @order.update_attributes order_params
    redirect_to '/orders'
  end

  def save_order_payments
    @order = Order.find params[:id]
    @order.update_attributes payments_params
  end

  protected
  def order_params
    params.require(:order).permit(:customer_name, :customer_phone, :deal_source, :project_name,
                                         :sub_date, :customer_type, :commision_price, :amout_price,
                                         :reduced_price,:no_reduced_price, :reduce_price, :real_price, :remark,
                                         orders_sales_attributes:{})
  end

  def payments_params
    params.require(:order).permit(payments_attributes:{})
  end
end
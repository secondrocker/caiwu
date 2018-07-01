class SubscriptionsController < ApplicationController
  def index
    @subs = Subscription.paginate(per_page:20,page:params[:page]).includes([:sales])
  end

  def new
    @sub = Subscription.new
  end

  def create
    @sub = Subscription.create(sub_params)
    redirect_to '/subscriptions'
  end


  def edit
    @sub = Subscription.find params[:id]
  end

  def destroy
    @sub = Subscription.find params[:id]
    @sub.destroy
    render js:"alert('已删除!');location.reload();"
  end

  def update
    @sub = Subscription.find params[:id]
    @sub.update_attributes sub_params
    redirect_to '/subscriptions'
  end

  def generate_order
    @sub = Subscription.find(params[:id])
    @sub.generate_order
    render js:"alert('生成成功!');location.reload();"
  end

  protected
  def sub_params
    params.require(:subscription).permit(:customer_name, :customer_phone, :deal_source, :project_name,
                                         :sub_date, :customer_type, :commision_price, :amout_price,
                                         :reduced_price,:no_reduced_price, :reduce_price, :real_price, :remark,
                                         subscriptions_sales_attributes:{})
  end
end
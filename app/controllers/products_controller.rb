class ProductsController < ApplicationController
  def show
    @product = Product.find_by(id: params[:id])
    return redirect_to root_path, alert: 'Produto não encontrado' if @product.nil?
    return redirect_to root_path, alert: 'Produto não encontrado' unless admin_signed_in? || @product.on_shelf?
    @current_price = @product.current_price
  end

  def search
    @products = Search.products(params[:query])
    @products = @products.filter(&:on_shelf?) unless admin_signed_in? || @products.empty?
    render 'home/index'
  end
  
  def update_status
    return unless admin_signed_in?
    product = Product.find(params[:id])
    if product.update(status: params[:status])
      redirect_to product, notice: 'Status atualizado com sucesso'
    else
      error_details = product.errors.full_messages.join(', ').downcase
      redirect_to product, alert: "Houve um erro. Para colocar um produto à venda, #{error_details}."
    end
  end
end
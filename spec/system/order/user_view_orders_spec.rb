require 'rails_helper'

describe "User enters orders page" do
  it "and views own orders" do
    user = create(:user)
    user_2 = create(:user, name: 'Maciel', email: 'maciel@meuemail.com')
    product_1 = create(:product, name: 'Caneca')
    product_2 = create(:product, name: 'Garrafa', sku: 'GRF9933')
    product_3 = create(:product, name: 'Jarra', sku: 'JRA68755')
    Timecop.freeze(1.month.ago) do
      create(:price, product: product_1, price_in_brl: "11.99")
      create(:price, product: product_2, price_in_brl: "4.99")
      create(:price, product: product_3, price_in_brl: "15.99")
    end
    create(:cart_item, product: product_1, quantity: 3, user: user)
    create(:cart_item, product: product_2, quantity: 7, user: user)
    create(:cart_item, product: product_3, quantity: 5, user: user_2)
    order_1 = create(:order, user: user, status: 'pending')
    order_2 = create(:order, user: user_2, status: 'pending')

    login_as(user, scope: :user)
    visit root_path
    click_on "Meus Pedidos"

    expect(page).to have_content "Pedido #{order_1.code} - Pendente"
    expect(page).to have_link "Detalhes do Pedido"
    expect(page).to have_content "Caneca Garrafa"
    expect(page).not_to have_content "Pedido #{order_2.code} - Pendente"
  end

  it "and there are no orders" do
    user = create(:user)
    
    login_as(user, scope: :user)
    visit root_path
    click_on "Meus Pedidos"

    expect(page).to have_content "Você ainda não possui nenhum pedido."
  end
end

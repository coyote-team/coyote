class JsonStrategy
  def initialize
    @strategy = FactoryGirl.strategy_by_name(:create).new
  end

  delegate :association, to: :@strategy

  def result(evaluation)
    @strategy.result(evaluation).to_json
  end
end

FactoryGirl.define do
  sequence :token do
    SecureRandom.hex(3)
  end
end

FactoryGirl.register_strategy(:json, JsonStrategy)
# FactoryGirl.json(:user)

class Sale < ApplicationRecord
  #has_many :subscriptions_sales
  #has_many :subscriptions,var: :subscriptions_sales
  #has_many :orders_sales
  #has_many :subscriptions,var: :orders_sales

  enum level:{normal_sale:1,leader:2,manager:3,director:4}
  enum leader_type:{new_leader:1,old_leader:2}
  LEVELS={normal_sale: '销售员',leader: '主管',manager: '经理',director: '总监'}
  LEADER_TYPES = {new_leader: '新主管',old_leader: '老主管'}
  def level_text
    Sale::LEVELS[self.level.to_sym]
  end

  def leader_type_text
    Sale::LEADER_TYPES[self.leader_type.to_sym] if self.leader?
  end

  def full_name
    return self.name if self.alias_name.blank?
    return "#{self.name}(#{self.alias_name})"
  end

  def self.leader_sales
    Sale.where(level:[:leader,:manager,:director]).map{|x| [x.full_name,x.id]}
  end
end

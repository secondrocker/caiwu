class ReportSetting < ApplicationRecord

  #配置
  def sets
    return {} if self.yml_data.blank?
    YAML.load self.yml_data
  end
end

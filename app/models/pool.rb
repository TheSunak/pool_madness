class Pool
  TIP_OFF = DateTime.new(2014, 3, 13, 12, 0, 0, '-4')

  def self.started?
    DateTime.now > TIP_OFF
  end
end

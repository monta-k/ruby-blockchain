class Output
  attr_reader :value, :script_pubkey

  def initialize args
    @value = args[:value]
    @script_pubkey = args[:script_pubkey]
  end
end
module Puppet::Parser::Functions
  newfunction(:memorysizeraw, :type => :rvalue) do |args|
    mem,unit = lookupvar('::memorysize').split
    mem = mem.to_f
    # Normalize mem to KiB
    case unit
      when nil:  mem *= (1<<0)
      when 'kB': mem *= (1<<10)
      when 'MB': mem *= (1<<20)
      when 'GB': mem *= (1<<30)
      when 'TB': mem *= (1<<40)
    end
    mem
  end
end

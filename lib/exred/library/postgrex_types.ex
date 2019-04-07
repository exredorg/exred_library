if Code.ensure_loaded?(Postgrex) do
  Postgrex.Types.define(Exred.Library.PostgrexTypes, [], [json: Jason, decode_binary: :copy])
end

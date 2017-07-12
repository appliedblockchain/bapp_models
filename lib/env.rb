module BAppModels
  RACK_ENV = ENV["RACK_ENV"] || "development"
end

KV_MULTI = ENV["KV_MULTI"] == "1"

# if BAppModels::RACK_ENV == "development"
#   Object.send *%i(remove_const KV_MULTI)
#   KV_MULTI = true
# end

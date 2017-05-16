module BAppModels
  ETH  = EthKV.new db: 11

  SETH = EthKV.new db: 12, shared: true
end

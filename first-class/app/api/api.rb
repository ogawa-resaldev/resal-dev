class API < Grape::API
  prefix 'api'
  mount V1::Root
end

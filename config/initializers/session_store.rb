# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_saasapp_session',
  :secret      => 'b8a222e932c52eb295a517e5559869465ae37736b33198939f49397cb4f7b79fb5d8403c9e9bcd8617180472954c57c23cd7a2ce2cefe0eae7d324508fd09c45'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

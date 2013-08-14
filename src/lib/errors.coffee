module.exports = showError = (error) ->
  switch error.status
    when Dropbox.ApiError.INVALID_TOKEN, Dropbox.ApiError.NOT_FOUND
    , Dropbox.ApiError.OVER_QUOTA
    , Dropbox.ApiError.RATE_LIMITED
    , Dropbox.ApiError.NETWORK_ERROR
    , Dropbox.ApiError.INVALID_PARAM
    , Dropbox.ApiError.OAUTH_ERROR
    , Dropbox.ApiError.INVALID_METHOD
    else
      # Caused by a bug in dropbox.js, in your application, or in Dropbox.
      throw error
namespace eval qc::oauth2 {

    namespace export \
        token_request
    namespace ensemble create

    # Grant Types
    variable authorization_code_grant_type "authorization_code"
    variable password_grant_type           "password"
    variable client_credentials_grant_type "client_credentials"
    variable refresh_grant_type            "refresh_token"

    ############################################################################
    #
    # Token request procs to authorise access and obtain a valid access token.
    #
    ############################################################################
    namespace eval token_request {

        namespace export \
            authorization_code \
            password \
            client_credentials \
            refresh
        namespace ensemble create

        proc authorization_code {
            server_url
            client_id
            {redirect_uri ""}
            {scope ""}
            {state ""}
        } {
            #| Request authorisation using the Authorization Code grant type.
            variable authorization_code_grant_type

            error "Not yet implemented."
        }

        proc password {
            server_url
            username
            password
            {client_id ""}
            {client_secret ""}
            {basic_auth false}
            {scope ""}
        } {
            #| Request authorisation using the Password grant type.
            variable password_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $password_grant_type \
                          ]

            if { $client_id ne ""
                 && $client_secret ne "" } {
                if { !$basic_auth } {
                    dict set data \
                        client_id $client_id \
                        client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { $scope ne "" } {
                dict set data scope $scope
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]
            
            return $response
        }

        proc client_credentials {
            server_url
            client_id
            client_secret
            {basic_auth false}
            {scope ""}
        } {
            #| Request authorisation using the Client Credentials grant type.
            variable client_credentials_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $client_credentials_grant_type \
                          ]

            if { !$basic_auth } {
                dict set data \
                    client_id $client_id \
                    client_secret $client_secret
            } else {
                set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                dict set http_post_flags -authorization "Basic $encoded_credentials"
            }

            if { $scope ne "" } {
                dict set data scope $scope
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]
            
            return $response
        }

        proc refresh {
            server_url
            refresh_token
            {client_id ""}
            {client_secret ""}
            {basic_auth false}
            {scope ""}
        } {
            #| Request authorisation using the Refresh Token grant type.
            variable refresh_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $refresh_grant_type \
                          ]

            if { $client_id ne ""
                 && $client_secret ne "" } {
                if { !$basic_auth } {
                    dict set data \
                        client_id $client_id \
                        client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { $scope ne "" } {
                dict set data scope $scope
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]

            return $response
        }
    }
}
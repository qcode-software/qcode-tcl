namespace eval qc::oauth2 {

    namespace export \
        authorize_code_link
        token_request
    namespace ensemble create

    # Grant Types
    variable authorization_code_grant_type "authorization_code"
    variable password_grant_type           "password"
    variable client_credentials_grant_type "client_credentials"
    variable refresh_grant_type            "refresh_token"

    proc authorize_code_uri {args} {
        #| Returns a link to seek authorization code from a service.

        qc::args \
            $args \
            -state ? \
            -scope ? \
            -redirect_uri ? \
            server_url \
            client_id

        return [qc::url \
                    $server_url \
                    ~ \
                    client_id \
                    redirect_uri \
                    scope \
                    state \
                   ]
    }

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

        proc authorization_code {args} {
            #| Request authorisation using the Authorization Code grant type.

            qc::args \
                $args \
                -client_secret ? \
                -redirect_uri ? \
                -basic_auth false \
                server_url \
                client_id \
                code

            variable authorization_code_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $authorization_code_grant_type \
                          code $code \
                          ]

            if { [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data \
                        client_id $client_id \
                        client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            } else {
                dict set data \
                    client_id $client_id
            }

            if { [info exists redirect_uri] } {
                dict set data \
                    redirect_uri $redirect_uri
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]

            return $response
        }

        proc password {args} {
            #| Request authorisation using the Password grant type.

            qc::args \
                $args \
                -client_id ? \
                -client_secret ? \
                -basic_auth false \
                -scope ? \
                server_url \
                username \
                password

            variable password_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $password_grant_type \
                          ]

            if { [info exists client_id]
                 && [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data \
                        client_id $client_id \
                        client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { [info exists $scope] } {
                dict set data scope $scope
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]

            return $response
        }

        proc client_credentials {args} {
            #| Request authorisation using the Client Credentials grant type.

            qc::args \
                $args \
                -basic_auth false \
                -scope ? \
                server_url \
                client_id \
                client_secret

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

            if { [info exists scope] } {
                dict set data scope $scope
            }

            set response [qc::http_post \
                              {*}$http_post_flags \
                              $server_url \
                              {*}$data \
                             ]

            return $response
        }

        proc refresh {args} {
            #| Request authorisation using the Refresh Token grant type.

            qc::args \
                $args \
                -client_id ? \
                -client_secret ? \
                -basic_auth false \
                -scope ? \
                server_url \
                refresh_token

            variable refresh_grant_type

            set http_post_flags [dict create \
                                    -accept "application/json; charset=utf-8" \
                                    ]
            set data [dict create \
                          grant_type $refresh_grant_type \
                          ]

            if { [info exists client_id]
                 && [info exists client_secret] } {
                if { !$basic_auth } {
                    dict set data \
                        client_id $client_id \
                        client_secret $client_secret
                } else {
                    set encoded_credentials [base64::encode "${client_id}:${client_secret}"]
                    dict set http_post_flags -authorization "Basic $encoded_credentials"
                }
            }

            if { [info exists scope] } {
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
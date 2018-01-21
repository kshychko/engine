[#-- Cognito User Pool --]

[#assign USERPOOL_OUTPUT_MAPPINGS =
    {
        REFERENCE_ATTRIBUTE_TYPE : {
            "UseRef" : true
        },
        NAME_ATTRIBUTE_TYPE : { 
            "Attribute" : "ProviderName"
        },
        ARN_ATTRIBUTE_TYPE : { 
            "Attribute" : "Arn"
        },
        URL_ATTRIBUTE_TYPE : { 
            "Attribute" : "ProviderURL"
        }
    }
]

[#function getUserPoolPasswordPolicy length="8" lowercase=true uppercase=true numbers=true symbols=true]
    [#return 
        {
            "PasswordPolicy" : {
                "MinimumLength"     : length,
                "RequireLowercase"  : lowercase,
                "RequireUppercase"  : uppercase,
                "RequireNumbers"    : numbers,
                "RequireSymbols"    : symbols
            }
        }
    ]
[/#function]

[#function getUserPoolAutoVerifcation email=false phone=false ]
    [#assign autoVerifyArray=[]]

    [#if email ]
        [#assign autoVerifyArray = autoVerifyArray + [ "email" ] ]
    [/#if]

    [#if phone ] 
        [#assign autoVerifyArray = autoVerifyArray + [ "phone_number" ]]
    [/#if]

    [#return 
        autoVerifyArray
    ]
[/#function]

[#macro createUserPool mode id name 
    mfa
    adminCreatesUser
    unusedTimeout
    tier="" 
    component="" 
    loginAliases=[] 
    autoVerify=[]
    passwordPolicy={}  
    dependencies="" 
    outputId=""
]

    [@cfResource 
        mode=mode
        id=id
        type="AWS::Cognito::UserPool"
        properties=
            {
                "UserPoolName" : name,
                "UserPoolTags" : getCfTemplateCoreTags("", tier, component),
                "MfaConfiguration" : mfa?then("ON","OFF"),
                "AdminCreateUserConfig" : {
                    "AllowAdminCreateUserOnly" : adminCreatesUser,
                    "UnusedAccountValidityDays" : unusedTimeout
                },
                "Schema" : [
                    {
                        "AttributeDataType" : "String",
                        "Name": "email",
                        "Required" : true,
                        "Mutable" : false,
                        "StringAttributeConstraints": {
                            "MinLength" : "3" 
                        }
                    }
                ]
            } + 
            attributeIfContent(
                "Policies",
                passwordPolicy 
            ) + 
            attributeIfContent(
                "AliasAttributes",
                loginAliases
            ) + 
            attributeIfContent(
                "AutoVerifiedAttributes", 
                autoVerify                
            )
        outputs=USERPOOL_OUTPUT_MAPPINGS
        outputId=outputId
        dependencies=dependencies
    /]
[/#macro]
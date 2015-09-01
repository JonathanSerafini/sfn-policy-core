
# SSL Security Policy Table :
# http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/elb-security-policy-table.html
#

SfnRegistry.register(:load_balancer_ssl_policies) do
  array!(
    {
      PolicyName: "SSLPolicy",
      PolicyType: "SSLNegotiationPolicyType",
      Attributes: array!(
        {
          Name: "Reference-Security-Policy",
          Value: "ELBSecurityPolicy-2014-10"
        }
      )
    }
  )
end


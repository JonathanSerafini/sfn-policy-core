
SparkleFormation.dynamic(:metadata_init_chef) do |_name|
  dynamic! :metadata_init_set, _name, "ChefInit",
    commands: {
      "10_boostrap_node" => {
        command: "/etc/chef/bootstrap.sh"
      }
    },
    files: {
      "/etc/chef/firstrun.json" => {
        content: {
          run_list: ref!(:chef_runlist),
        }
      },
      "/etc/chef/bootstrap.sh" => {
        encoding: "string",
        mode: "000750",
        context: {
          Environment: state!(:environment),
          StackName: registry!(:context_name)
        },
        content: <<-EOC
#!/bin/bash
export PATH="/usr/local/bin:$PATH"

env_name="{{Environment}}"
stack_name="{{StackName}}"

aws_url="http://169.254.169.254/latest"
instance="$(curl -s ${aws_url}/meta-data/instance-id)"
instance="${instance/i-/}"
node_name="${stack_name}-${instance}"

if [ -f "/etc/chef/validation.save" ]; then
  mv /etc/chef/validation.save /etc/chef/validation.pem
  rm /etc/chef/client.pem
fi

sed -i .bak \
    -e "s@node_name.*@node_name \\"$node_name\\"@" \
    /etc/chef/client.rb
rm /etc/chef/client.rb.bak

mkdir -p /etc/cfn/scripts
exit 0
        EOC
        }
    }

  dynamic! :metadata_init_set, _name, "ChefRun",
    commands: {
      "20_run_chef" => {
        command: join!(
          "chef-client --environment ", state!(:environment),
          " --json-attributes /etc/chef/firstrun.json"
        )
      }
    }
end


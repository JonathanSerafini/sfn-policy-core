
SfnRegistry.register(:database_params) do
  parameters do
    db_instance do
      type "String"
      description "Database instance type"
      default "db.m3.medium"
    end

    db_username do
      type "String"
      description "Database admin account"
      default "root"
    end

    db_password do
      type "String"
      description "Database admin password"
    end

    db_backup_retention do
      type "Number"
      description "Database backup retention in days"
      default "7"
    end

    db_disk_type do
      type "String"
      description "Database storage type"
      default "gp2"
      allowed_values %w(standard gp2 io1)
    end

    db_disk_size do
      type "Number"
      description "Database storage size in gigs"
      default "100"
    end
  end
end


module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "germanywestcentral"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                     = module.naming.storage_account.name_unique
    location                 = module.rg.groups.demo.location
    resource_group_name      = module.rg.groups.demo.name
    account_replication_type = "LRS"
  }
}

module "redis" {
  source  = "codectl/redis/azure"
  version = "~> 1.0"

  cache = {
    name                = module.naming.redis_cache.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    sku_name            = "Premium"
    capacity            = 1
    family              = "P"

    redis_configuration = {
      rdb_backup_enabled            = true
      rdb_backup_frequency          = 60
      rdb_backup_max_snapshot_count = 1
      rdb_storage_connection_string = module.storage.account.primary_blob_connection_string
    }
  }
}

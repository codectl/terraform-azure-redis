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
    shard_count         = 3
  }
}

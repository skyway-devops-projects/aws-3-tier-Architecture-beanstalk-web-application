output "memcached_endpoint" {
  value = aws_elasticache_cluster.memcached_cluster.cache_nodes[0].address
}

output "memcached_port" {
  value = aws_elasticache_cluster.memcached_cluster.cache_nodes[0].port
}
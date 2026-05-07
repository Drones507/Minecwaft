output "minecraft_server_ip" {
  description = "Public IP address of the Minecraft EC2 instance."
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_connection_string" {
  description = "Paste this into Minecraft → Multiplayer → Add Server."
  value       = "${aws_instance.minecraft.public_ip}:${var.minecraft_port}"
}

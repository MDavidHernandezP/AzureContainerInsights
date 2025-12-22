resource "azurerm_role_assignment" "trainer" {
  scope                = var.scope
  role_definition_name = "Contributor"
  principal_id         = var.principal_id
}

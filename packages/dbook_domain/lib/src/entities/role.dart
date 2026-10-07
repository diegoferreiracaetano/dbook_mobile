/// Papel do usuário — espelha `Role` do backend. `unknown` é um papel que o
/// backend criou depois desta versão do app: tratado como "sem privilégio".
enum Role { client, support, catalogManager, superAdmin, unknown }

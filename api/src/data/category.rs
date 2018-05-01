use data::schema::categories;

#[derive(Serialize, Deserialize, Identifiable, Queryable)]
#[table_name = "categories"]
pub struct Category {
    pub id: i32,
    pub name: String,
}

/*
base class for data models
data model needs to implement toMap() for persistence with db/ local storage
 */
abstract class DataModel {
  Map<String, dynamic> toJson();
}
-- 1.1

Create Table Cities (
	[CityID] int Not Null,
	[Name] varchar(100) Not Null,

	Constraint PK_CityID Primary Key Clustered (CityID asc)
)

Create Table Preschools (
	[PreschoolID] int Not Null,
	[CityID] int Not Null,
	[Street] varchar(100) Not Null,
	[PropertyNo] varchar(10) Not Null,
	[Capacity] int Not Null,

	Constraint PK_PreschoolID Primary Key Clustered (PreschoolID asc),
	Constraint FK_Preschools_Cities_CityID Foreign Key (CityID) References Cities(CityID)
)

Create Table Applications (
	[ApplicationID] int Not Null,
	[ChildName] varchar(100) Not Null,
	[ChildSurname] varchar(100) Not Null,
	[ChildPESEL] char(13) Not Null,
	[ChildBirthday] datetime Not Null,
	[Preschool1ID] int Not Null,
	[Preschool2ID] int Not Null,
	[Preschool3ID] int Not Null,
	[AssignedPreschoolID] int Null,
	[CityID] int Not Null,
	
	Constraint PK_ApplicationID Primary Key Clustered (ApplicationID asc),
	Constraint FK_Applications_Preschools_Preschool1 Foreign Key (Preschool1ID) References Preschools(PreschoolID),
	Constraint FK_Applications_Preschools_Preschool2 Foreign Key (Preschool2ID) References Preschools(PreschoolID),
	Constraint FK_Applications_Preschools_Preschool3 Foreign Key (Preschool3ID) References Preschools(PreschoolID),
	Constraint FK_Applications_Preschools_AssignedPreschool Foreign Key (AssignedPreschoolID) References Preschools(PreschoolID),
	Constraint FK_Applications_Cities_CityID Foreign Key (CityID) References Cities(CityID)
)

-- 1.2

Alter Table Preschools
	Add RegisteredCount int Default(0)

-- 1.3

Alter Table Preschools
	Alter Column PropertyNo varchar(20)

-- 1.4

Insert Into Cities Values (1, 'Warszawa')

-- 1.5

Insert Into Preschools (PreschoolID, CityID, Street, PropertyNo, Capacity) 
	Values (1, 1, 'Polna', '4123', 100),
		   (2, 1, 'Zielona', '5754', 150),
		   (3, 1, 'W¹ska', '6941', 300)

Set DateFormat MDY
Insert Into Applications (ApplicationID, ChildName, ChildSurname, ChildPESEL, ChildBirthday, Preschool1ID, Preschool2ID, Preschool3ID, AssignedPreschoolID, CityID)
	Values (1, 'Jaœ', 'Fasola', '0210304832143', '2002-10-30', 1, 2, 3, Null, 1),
		   (2, 'Grzegorz', 'Kruchy', '0108124832143', '2001-08-12', 1, 2, 3, Null, 1)

-- 1.6

Update Preschools Set RegisteredCount = (Select Count(*) From Applications Where AssignedPreschoolID = PreschoolID)
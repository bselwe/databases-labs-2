-- Po wstawieniu nowych rekordów do tabeli przedszkola, automatycznie
-- podejmuje próbê przypisania tych przedszkoli do z³o¿onych wniosków
-- o pustej wartoœci w kolumnie AssignedPreschoolID i pochodz¹cych
-- z tej samej miejscowoœci, co miejscowoœæ przedszkola.

Create Trigger trAssignPreschools On Preschools
After Insert
As
Begin
	Save Transaction BeforeUpdate

	Begin Try
		Declare @PreschoolID int
		Declare @CityID int
		Declare @Capacity int

		Declare InsertedPreschools Cursor Local For
			Select PreschoolID, CityID, Capacity From Inserted

		Open InsertedPreschools
		Fetch Next From InsertedPreschools Into @PreschoolID, @CityID, @Capacity

		While @@FETCH_STATUS = 0
		Begin
			-- Brak miejsca w przedszkolu
			If @Capacity = 0
				Continue

			Declare @ApplicationID int
			Declare WaitingApplications Cursor Local For
				Select ApplicationID From Applications 
				Where AssignedPreschoolID Is Null And CityID = @CityID
				Order By ChildBirthday

			Open WaitingApplications
			Fetch Next From WaitingApplications Into @ApplicationID

			While @@FETCH_STATUS = 0
			Begin
				-- Wykorzystano wszystkie miejsca w przedszkolu
				If @Capacity = 0
					Break
				
				Update Applications Set AssignedPreschoolID = @PreschoolID Where ApplicationID = @ApplicationID
				
				Update Preschools Set RegisteredCount = i.RegisteredCount + 1
				From Preschools p
				Join Inserted i on i.PreschoolID = i.PreschoolID and i.PreschoolID = @PreschoolID

				Set @Capacity = @Capacity - 1

				Fetch Next From WaitingApplications Into @ApplicationID
			End

			Close WaitingApplications
			Deallocate WaitingApplications

			Fetch Next From InsertedPreschools Into @PreschoolID, @CityID, @Capacity
		End

		Close InsertedPreschools
		Deallocate InsertedPreschools
	End Try

	Begin Catch
		RollBack Transaction BeforeUpdate
		Return
	End Catch
End
Create Procedure spAssignPreschools @CityID int
As
Begin
	Begin Try
		Set Transaction Isolation Level Read Committed
		Begin Transaction
			Declare @ApplicationID int
			Declare @Preschool1ID int
			Declare @Preschool2ID int
			Declare @Preschool3ID int
			Declare @AssignedPreschoolID int

			Declare WaitingApplications Cursor Local For
				Select ApplicationID, Preschool1ID, Preschool2ID, Preschool3ID From Applications 
				Where AssignedPreschoolID Is Null And CityID = @CityID
				Order By ChildBirthday

			Open WaitingApplications
			Fetch Next From WaitingApplications Into @ApplicationID, @Preschool1ID, @Preschool2ID, @Preschool3ID

			While @@FETCH_STATUS = 0
			Begin
				Set @AssignedPreschoolID = (Select PreschoolID From Preschools Where PreschoolID = @Preschool1ID And RegisteredCount < Capacity)

				-- Nie uda³o siê przypisaæ do 1. przedszkola
				If @AssignedPreschoolID Is Null
				Begin
					Set @AssignedPreschoolID = (Select PreschoolID From Preschools Where PreschoolID = @Preschool2ID And RegisteredCount < Capacity)
				End

				-- Nie uda³o siê przypisaæ do 1. i 2. przedszkola
				If @AssignedPreschoolID Is Null
				Begin
					Set @AssignedPreschoolID = (Select PreschoolID From Preschools Where PreschoolID = @Preschool3ID And RegisteredCount < Capacity)
				End

				-- Znaleziono przedszkole
				If @AssignedPreschoolID Is Not Null
				Begin
					Print 'Found preschool (' + Cast(@AssignedPreschoolID as varchar) + ') for application: ' + Cast(@ApplicationID as varchar)
					Update Applications Set AssignedPreschoolID = @AssignedPreschoolID Where ApplicationID = @ApplicationID
					Update Preschools Set RegisteredCount = RegisteredCount + 1 Where PreschoolID = @AssignedPreschoolID
				End

				-- Nie uda³o siê przypisaæ do ¿adnego przedszkola
				If @AssignedPreschoolID Is Null
				Begin
					Print 'Cannot find preschool for application: ' + Cast(@ApplicationID as varchar)
					Delete From Applications Where ApplicationID = @ApplicationID
				End

				Fetch Next From WaitingApplications Into @ApplicationID, @Preschool1ID, @Preschool2ID, @Preschool3ID
			End

			Close WaitingApplications
			Deallocate WaitingApplications
		Commit Transaction
		Print 'Transaction committed'
	End Try

	Begin Catch
		Rollback Transaction
		Print 'Transaction rolled back'
		Select ERROR_MESSAGE() As ErrorMessage
	End Catch
End
Go
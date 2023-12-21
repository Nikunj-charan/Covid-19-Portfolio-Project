use PortfolioProject

Select*
from NashvilleHousingData

-------------------------------------------------------------------------------

-- Populating PropertyAddress where Values are Null --

Select A.ParcelID,A.UniqueID,A.PropertyAddress,B.ParcelID,B.UniqueID,B.PropertyAddress
from NashvilleHousingData as A
join NashvilleHousingData as B
on A.ParcelID = B.ParcelID
and A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousingData as A
Join NashvilleHousingData as B
on A.ParcelID = B.ParcelID
and A.UniqueID <> B.UniqueID
Where A.PropertyAddress is Null

-------------------------------------------------------------------------------
------ Deconcatenating Street and city names from the PropertyAddress column --------

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
from NashvilleHousingData

Alter table NashvilleHousingData
ADD StreetAddress nvarchar(255),
	CityOrCounty nvarchar(255);
  
Update NashvilleHousingData
SET StreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1),
	CityOrCounty = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress));

-------------------------------------------------------------------------------------------------------
----- Deconcatenating Street and City names in the OwnerAddress column-----------

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as StreetName,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2) as CityName,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1) as StateName
from NashvilleHousingData

Alter table NashvilleHousingData
Add OwnerResidenceStreet nvarchar(255),
	OwnerResidenceCity nvarchar(255),
	OwnerResidenceState nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerResidenceStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerResidenceCity =   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerResidenceState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1);

UPDATE NashvilleHousingData
SET OwnerResidenceStreet = ISNULL(OwnerResidenceStreet,'Not Applicable'),
	OwnerResidenceState = ISNULL(OwnerResidenceState,'Not Applicable'),
	OwnerResidenceCity = ISNULL(OwnerResidenceCity,'Not Applicable');

------------------------------------------------------------------------------
------ Setting SoldAsVacant Column to Non Boolean Values of YES & NO ---------

Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant

Select SoldAsVacant,
			CASE When SoldAsVacant = 0 Then 'NO'
			When SoldAsVacant = 1 Then 'YES'
			Else CAST(SoldAsVacant as varchar)
			End
from NashvilleHousingData
 
Alter Table NashvilleHousingData
Alter column SoldAsVacant varchar(5)
		
Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 0 Then 'NO'
				   When SoldAsVacant = 1 Then 'YES'
				   Else SoldAsVacant
				   End

--------------------------------------------------------------------------------------
---------- Removing Duplicate enteries from the Entire table -------------------------

With RowNumCTE as 
(Select ROW_NUMBER()OVER(Partition by ParcelID,PropertyAddress,
									  SalePrice,SaleDate,LegalReference
									  Order by UniqueID) as Row_num
from NashvilleHousingData)
DELETE
from RowNumCTE
where Row_num >1
-----------------------------------------------------------------------------------------
--------------------- Deleting unused/Duplicate Columns ------------------------------
ALTER TABLE NashvilleHousingData
Drop Column TaxDistrict,OwnerAddress,PropertyAddress
--------------------------------------------------------------------------------------
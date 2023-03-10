-- CLEANING DATA IN SQL

--selecting whole dataframe for initial inspection
SELECT *
FROM dbo.housingdata;


-------------------------------------------------------------------------------------------


-- POPULATE PROPERTY ADDRESS NULL VALUES

-- filtering by where property address in null
SELECT *
FROM dbo.housingdata
WHERE PropertyAddress is null
ORDER BY ParcelID;

-- joining two copies of housingdata to populate property address by parcelid
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.housingdata a
JOIN dbo.housingdata b
  ON a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;

-- updating housingdata propertyaddress null values using our joined tables and ISNULL()
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.housingdata a
JOIN dbo.housingdata b
  ON a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 WHERE a.PropertyAddress is null;


 ----------------------------------------------------------------------------------------------------------------

 -- UNPACKING ADDRESS INTO MULTIPLE COLUMNS

 SELECT PropertyAddress
 FROM dbo.housingdata

-- seperate property address into and city and address columns
 SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
        SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
 FROM dbo.housingdata

 --create address column
 ALTER TABLE housingdata
 ADD PropertySplitAddress Nvarchar(255)

 UPDATE housingdata
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

 --create city column
 ALTER TABLE housingdata
 ADD PropertySplitCity Nvarchar(255)

 UPDATE housingdata
 SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------

-- UNPACK OWNERADDRESS COLUMN

--
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM housingdata;

--create OwnerSplitAddress column
 ALTER TABLE housingdata
 ADD OwnerSplitAddress Nvarchar(255)

 UPDATE housingdata
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 --create OwnerSplitCity column
 ALTER TABLE housingdata
 ADD OwnerSplitCity Nvarchar(255)

 UPDATE housingdata
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  --create OwnerSplitState column
 ALTER TABLE housingdata
 ADD OwnerSplitState Nvarchar(255)

 UPDATE housingdata
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 ---------------------------------------------------------------------------------------------------------------

 -- REMOVE DUPLICATES

 --create a cte to check for duplicate rows
 WITH RowNumCTE AS(
 SELECT *,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID) row_num
 FROM housingdata
 )
 --delete duplicate rows
DELETE
 FROM RowNumCTE
 WHERE row_num > 1

 --not always a good idea just a demonstration of code

 -----------------------------------------------------------------------------------------------------------------

 --CHECK COLUMNS FOR STANDARDIZED VALUES

 --checking SoldAsVacant
 SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
 FROM housingdata
 GROUP BY SoldAsVacant
 ORDER BY 2

 --checking LandUse
 SELECT DISTINCT(LandUse), Count(LandUse)
 FROM housingdata
 GROUP BY LandUse
 ORDER BY 2

 -- looking for values such as part of data = 'yes' and other = 'Y' etc.

 -----------------------------------------------------------------------------------------------------------------

 --REMOVE UNUSED COLUMNS

 SELECT * FROM housingdata

 ALTER TABLE housingdata
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 --not always a good idea just a demonstration of code
-- Cleaning Data in SQL Queries

SELECT *
FROM sqlproject.dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM sqlproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateFormat DATE

UPDATE NashvilleHousing
SET SaleDateFormat = CONVERT(DATE,SaleDate)

SELECT SaleDateFormat,CONVERT(DATE,SaleDate)
FROM sqlproject.dbo.NashvilleHousing

-- Populate Property Address Data

SELECT *
FROM sqlproject.dbo.NashvilleHousing
WHERE PropertyAddress IS  NULL

SELECT tableA.ParcelID,tableA.PropertyAddress,tableB.ParcelID,tableB.PropertyAddress,
	   ISNULL(tableA.PropertyAddress, tableB.PropertyAddress)
FROM sqlproject..NashvilleHousing tableA
JOIN sqlproject..NashvilleHousing tableB
ON tableA.ParcelID = tableB.ParcelID
AND tableA.[UniqueID ] <> tableB.[UniqueID ]
WHERE tableA.PropertyAddress IS NULL

UPDATE tableA
SET PropertyAddress = ISNULL(tableA.PropertyAddress, tableB.PropertyAddress)
FROM sqlproject..NashvilleHousing tableA
JOIN sqlproject..NashvilleHousing tableB
ON tableA.ParcelID = tableB.ParcelID
AND tableA.[UniqueID ] <> tableB.[UniqueID ]
WHERE tableA.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns(Address, City, State)

--PropertyAddress column

SELECT PropertyAddress
FROM sqlproject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS StreetAddress,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM sqlproject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress column

SELECT OwnerAddress
FROM sqlproject..NashvilleHousing 

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM sqlproject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to YES and NO in " Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM sqlproject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM sqlproject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END


-- Remove Duplicates

WITH  RowNum AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM sqlproject..NashvilleHousing
)
DELETE
FROM RowNum
WHERE row_num > 1

-- Delete unused columns

ALTER TABLE sqlproject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE sqlproject..NashvilleHousing
DROP COLUMN SaleDate
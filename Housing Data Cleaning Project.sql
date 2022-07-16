/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProjects.dbo.HousingData
-----------------------------------------------------------------------------------

------- Properly Format and standardize the Date Column
Select SaleDate, convert(Date, SaleDate) as ConvertedSaleDate
from PortfolioProjects.dbo.HousingData;

ALter Table HousingData
Add ConvertedSaleDate Date;

Update PortfolioProjects.dbo.HousingData
set ConvertedSaleDate = convert(Date, SaleDate);
------------------------------------------------------------------------------------

---------- Populating the Property Address column having NULL values with data
Select *
From PortfolioProjects.dbo.HousingData
Order by ParcelID;

Select aa.ParcelID, aa.PropertyAddress, bb.ParcelID, bb.PropertyAddress, ISNULL(aa.PropertyAddress,bb.PropertyAddress) as UpdatedAddress
From PortfolioProjects.dbo.HousingData aa
JOIN PortfolioProjects.dbo.HousingData bb
	on aa.ParcelID = bb.ParcelID
	AND aa.[UniqueID ] <> bb.[UniqueID ]
Where aa.PropertyAddress is null;

Update aa
SET PropertyAddress = ISNULL(aa.PropertyAddress,bb.PropertyAddress)
From PortfolioProjects.dbo.HousingData aa
JOIN PortfolioProjects.dbo.HousingData bb
	on aa.ParcelID = bb.ParcelID
	AND aa.[UniqueID ] <> bb.[UniqueID ]
Where aa.PropertyAddress is null;
-------------------------------------------------------------------------------------

------------Breaking down Property Address into seperate columns (Address, City, State)
Select PropertyAddress
From PortfolioProjects.dbo.HousingData;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as PropertyAddress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as PropertyCity
From PortfolioProjects.dbo.HousingData;

Alter Table PortfolioProjects.dbo.HousingData
add UpdatedPropertyAddress nvarchar(255);

Alter Table PortfolioProjects.dbo.HousingData
add PropertyCity nvarchar(255);

Update PortfolioProjects.dbo.HousingData
set UpdatedPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

Update PortfolioProjects.dbo.HousingData
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

Select *
From PortfolioProjects.dbo.HousingData;

Select OwnerAddress
From PortfolioProjects.dbo.HousingData;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerAddressSplit
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerCitySplit
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerStateSplit
From PortfolioProjects.dbo.HousingData;

ALTER TABLE PortfolioProjects.dbo.HousingData
Add OwnerAddressSplit Nvarchar(255);

ALTER TABLE PortfolioProjects.dbo.HousingData
Add OwnerCitySplit Nvarchar(255);

ALTER TABLE PortfolioProjects.dbo.HousingData
Add OwnerStateSplit Nvarchar(255);

Update PortfolioProjects.dbo.HousingData
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

Update PortfolioProjects.dbo.HousingData
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

Update PortfolioProjects.dbo.HousingData
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);
-------------------------------------------------------------------------------------------------------

----------------Update Y and N values to 'Yes' and 'No' in SoldAsVacant Column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.HousingData
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END as SoldUpdated
From PortfolioProjects.dbo.HousingData;

Update PortfolioProjects.dbo.HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
----------------------------------------------------------------------------------------------------

------------------ Removing duplicate values
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects.dbo.HousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects.dbo.HousingData
)
Delete
From RowNumCTE
Where row_num > 1;
-------------------------------------------------------------------------------------------

----------------Deleting unused columns
Select *
From PortfolioProjects.dbo.HousingData;


ALTER TABLE PortfolioProjects.dbo.HousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate;



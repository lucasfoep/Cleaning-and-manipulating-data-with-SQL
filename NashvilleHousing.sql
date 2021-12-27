-- Update statement alone isn't working so I will have to create a new column and populate it with dates in the format I want
-- Creating a new column.

alter table NashVilleHousing
add SaleDateConverted date;

-- Populating it with SalesDate converted to Date.

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)


-- Checking where the PropertyAddress column is null and using isnull to populate it.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Updating the PropertyAddress column with its populated version.

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Splitting ProppertyAddress at the comma.
-- Finding how it will look like.

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as PropertyStreetAddress,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as PropertyCity
from NashvilleHousing

-- Creating StreetAddress column.

alter table NashvilleHousing
add PropertyStreetAddress nvarchar(255)

-- Populating the new column with the substring we want it to look like.

update NashvilleHousing
set PropertyStreetAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

-- Creating City column.

alter table NashvilleHousing
add PropertyCity nvarchar(255)

-- Populating the new column with the substring we want it to look like.

update NashvilleHousing
set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

-- Now doing the same for the OwnerAddress column using parsename instead of substring.
-- Splitting it at the commas and seeing how it looks like.

select
parsename(replace(OwnerAddress, ',', '.'), 3) as OwnerStreetAddress,
parsename(replace(OwnerAddress, ',', '.'), 2) as OwnerCity,
parsename(replace(OwnerAddress, ',', '.'), 1) as OwnerState
from NashvilleHousing
where OwnerAddress is not null

-- Creating new columns and populating them.

alter table NashvilleHousing
add OwnerStreetAddress nvarchar(255)

update NashvilleHousing
set OwnerStreetAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCity nvarchar(255)

update NashvilleHousing
set OwnerCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerState nvarchar(255)

update NashvilleHousing
set OwnerState = parsename(replace(OwnerAddress, ',', '.'), 1)

-- Finding out that there are different values for yes and no at the SoldAsVacant column.

select distinct(SoldAsVacant), count(SoldAsVacant) as Frequency
from NashvilleHousing
group by SoldAsVacant
order by 2

-- Replacing Ys with Yes and Ns with No.

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end as NewSoldAsVacant
from NashvilleHousing
where SoldAsVacant = 'N'

-- Updating the column

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
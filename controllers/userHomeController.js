import { findAllDrugsByLocation, searchDrugNameByLocation } from "../model/drugs-userModel.js";
import db from "../config/data.js";

export const getAllDrugsByLocationController = (req, res, next) => {
  const userLat = parseFloat(req.params.lat);
  const userLang = parseFloat(req.params.lng);

  if (isNaN(userLat) || isNaN(userLang)) {
    return res.status(400).json({
      message: 'User location(lat,lng) is required'
    });
  }

  findAllDrugsByLocation(userLang, userLat, (err, result) => {
    if (err)
      return res.status(500).json({ message: err.message });

    //const baseUrl = process.env.BASE_URL || `${req.protocol}://${req.get('host')}`;

  const updatedResult = result.map(drug => {
  return {
    id: drug.drug_id,          
    drug_id: drug.drug_id,     
    branch_id: drug.branch_id,  
    name: drug.drug_name,
    price: drug.drug_price,
    locationLabel: drug.pharmacy_name,
    image_url: drug.image_url || null
  };
});

    return res.status(200).json({
      status: 'success',
      result: updatedResult.length,
      data: {
        result: updatedResult
      }
    });
  }); 
};

export const searchDrugByLocationController = (req, res, next) => {
  const userLat = parseFloat(req.params.lat);
  const userLang = parseFloat(req.params.lng);
  const key = req.params.key;

  if (isNaN(userLat) || isNaN(userLang)) {
    return res.status(400).json({
      message: 'User location(lat,lng) is required'
    });
  }

  searchDrugNameByLocation(key, userLang, userLat, (err, result) => {
    if (err)
      return res.status(500).json({ message: err.message });

    if (result.length === 0) {
      return res.status(404).json({
        message: 'This drug is out of stock'
      });
    }

   // const baseUrl = process.env.BASE_URL || `${req.protocol}://${req.get('host')}`;

    const updatedResult = result.map(drug => ({
  id: drug.drug_id,          
  drug_id: drug.drug_id,      
  branch_id: drug.branch_id,  
  name: drug.drug_name,
  price: drug.drug_price,
  locationLabel: drug.pharmacy_name,
  image_url: drug.image_url || null
}));

    return res.status(200).json({
      status: 'success',
      result: result.length,
      data: {
        result: updatedResult
      }
    });
  });
};
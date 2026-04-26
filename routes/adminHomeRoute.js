import express from 'express';
import { restrictTO ,protect} from '../controllers/authController.js';
import { upload } from '../utills/multer.js';
import { getAllDrugsController,addNewDrugController,updateDrugController,deleteDrugController,searchDrugController,getTotalStockController,getLowStockController } from '../controllers/adminHomeController.js';
export const adminHomeRouter=express.Router();
adminHomeRouter.use(protect)
adminHomeRouter.use(restrictTO('admin'));
adminHomeRouter.get('/alldrugs',getAllDrugsController);
adminHomeRouter.post('/drugs',upload.single('image_name'),addNewDrugController);
adminHomeRouter.patch('/drugs/:branchId/:drugId',updateDrugController);
adminHomeRouter.delete('/drugs/:branchId/:drugId',deleteDrugController);
adminHomeRouter.get('/drugs/search/:key',searchDrugController);
adminHomeRouter.get('/drugs/total',getTotalStockController);
adminHomeRouter.get('/drugs/low',getLowStockController);
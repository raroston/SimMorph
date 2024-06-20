import numpy as np

def convertFudicialToNP(fnode):
  numberOfLM=fnode.GetNumberOfControlPoints()
  lmData=np.zeros((numberOfLM,3))
  for i in range(numberOfLM):
    loc = fnode.GetNthControlPointPosition(i)
    lmData[i,:]=np.asarray(loc)
  return lmData

def applyScale(scaleFactor, fnode):
    lmArray = convertFudicialToNP(fnode)
    center = lmArray.mean(0)
    transformNode = slicer.mrmlScene.AddNewNodeByClass("vtkMRMLLinearTransformNode")
    # translate to origin
    translate=vtk.vtkTransform()
    translate.Translate(center*-1)
    transformNode.SetMatrixTransformToParent(translate.GetMatrix())
    fnode.SetAndObserveTransformNodeID(transformNode.GetID())
    slicer.vtkSlicerTransformLogic().hardenTransform(fnode)
    # scale
    scale=vtk.vtkTransform()
    scale.Scale([scaleFactor,scaleFactor,scaleFactor])
    transformNode.SetMatrixTransformToParent(scale.GetMatrix())
    fnode.SetAndObserveTransformNodeID(transformNode.GetID())
    slicer.vtkSlicerTransformLogic().hardenTransform(fnode)
    # invert translation
    invert = translate.GetInverse()
    transformNode.SetMatrixTransformToParent(invert.GetMatrix())
    fnode.SetAndObserveTransformNodeID(transformNode.GetID())
    slicer.vtkSlicerTransformLogic().hardenTransform(fnode)
    # clean update
    slicer.mrmlScene.RemoveNode(transformNode)


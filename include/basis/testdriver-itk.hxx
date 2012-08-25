/**
 * @file  testdriver-itk.hxx
 * @brief ITK-based implementation of test driver.
 *
 * This implementation of the test driver utilizes the ITK.
 *
 * This file is in parts a modified version of the itkTestDriverInclude.h
 * file which is part of the TestKernel module of the ITK 4 project and
 * in other parts contains code from the ImageCompareCommand.cxx file
 * which is part of the ITK 3.20 release.
 *
 * Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen<br />
 * Copyright (c) Insight Software Consortium.<br />
 * Copyright (c) 2011 University of Pennsylvania.
 *
 * Portions of this file are subject to the VTK Toolkit Version 3 copyright.
 *
 * For complete copyright, license and disclaimer of warranty information
 * please refer to the COPYRIGHT file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

 /*=========================================================================
 *
 *  Copyright Insight Software Consortium
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *=========================================================================*/
/*=========================================================================
 *
 *  Portions of this file are subject to the VTK Toolkit Version 3 copyright.
 *
 *  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
 *
 *  For complete copyright, license and disclaimer of warranty information
 *  please refer to the NOTICE file at the top of the ITK source tree.
 *
 *=========================================================================*/

#pragma once
#ifndef _BASIS_TESTDRIVER_ITK_HXX
#define _BASIS_TESTDRIVER_ITK_HXX


// avoid dependency on all IO libraries which are commonly used
// has to be undefined before including the reader or writer
#ifdef ITK_IO_FACTORY_REGISTER_MANAGER
#  undef ITK_IO_FACTORY_REGISTER_MANAGER
#endif


#include <itkImage.h>
#include <itkImageFileReader.h>
#include <itkImageFileWriter.h>
#include <itkRescaleIntensityImageFilter.h>
#include <itkExtractImageFilter.h>
#if defined(ITK_VERSION_MAJOR) && ITK_VERSION_MAJOR < 4
#  include <itkDifferenceImageFilter.h>
#else
#  include <itkTestingComparisonImageFilter.h>
#endif
#include <itkOrientImageFilter.h>

#include <itkGDCMImageIOFactory.h>
#include <itkMetaImageIOFactory.h>
#include <itkJPEGImageIOFactory.h>
#include <itkPNGImageIOFactory.h>
#include <itkTIFFImageIOFactory.h>
#include <itkBMPImageIOFactory.h>
#include <itkVTKImageIOFactory.h>
#include <itkNrrdImageIOFactory.h>
#include <itkGiplImageIOFactory.h>
#include <itkNiftiImageIOFactory.h>
#include <itkObjectFactoryBase.h>


// maximum number of dimensions of test and baseline images
#define ITK_TEST_DIMENSION_MAX BASIS_MAX_TEST_IMAGE_DIMENSION


// ---------------------------------------------------------------------------
void RegisterRequiredFactories()
{
    itk::ObjectFactoryBase::RegisterFactory(itk::MetaImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::GDCMImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::JPEGImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::VTKImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::PNGImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::TIFFImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::BMPImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::NrrdImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::GiplImageIOFactory::New());
    itk::ObjectFactoryBase::RegisterFactory(itk::NiftiImageIOFactory::New());
}

// ---------------------------------------------------------------------------
// This implementation of the image regression test was copied from the
// Testing/Code/IO/ImageCompareCommand.cxx file of the ITK 3.20 release.
// Then the function has been modified such that first of all the function
// prototype matches the one of the corresponding function of the ITK 4
// TestKernel module and furthermore the generation of the reports is
// identical as well. This includes the extraction of the center slice instead
// of the first slice to generate PNG images for inclusion in the report.
//
// The orientationInsensitive flag has been added to allow for differences
// in the image orientations on disk.
int RegressionTestImage (const char*  testImageFilename,
                         const char*  baselineImageFilename,
                         int          reportErrors,
                         double       intensityTolerance,
                         unsigned int numberOfPixelsTolerance,
                         unsigned int radiusTolerance,
                         bool         orientationInsensitive)
{
  // Use the factory mechanism to read the test and baseline files and convert them to double
  typedef itk::Image<double,        ITK_TEST_DIMENSION_MAX> ImageType;
  typedef itk::Image<unsigned char, ITK_TEST_DIMENSION_MAX> OutputType;
  typedef itk::Image<unsigned char, 2>                      DiffOutputType;
  typedef itk::ImageFileReader<ImageType>                   ReaderType;

  // Read the baseline file
  ReaderType::Pointer baselineReader = ReaderType::New();
    baselineReader->SetFileName(baselineImageFilename);
  try
    {
    baselineReader->UpdateLargestPossibleRegion();
    }
  catch (itk::ExceptionObject& e)
    {
    std::cerr << "Exception detected while reading " << baselineImageFilename << " : "  << e;
    return 1000;
    }

  // Read the file generated by the test
  ReaderType::Pointer testReader = ReaderType::New();
    testReader->SetFileName(testImageFilename);
  try
    {
    testReader->UpdateLargestPossibleRegion();
    }
  catch (itk::ExceptionObject& e)
    {
    std::cerr << "Exception detected while reading " << testImageFilename << " : "  << e << std::endl;
    return 1000;
    }

  ImageType::Pointer baselineImage = baselineReader->GetOutput();
  ImageType::Pointer testImage     = testReader    ->GetOutput();

  testImage    ->DisconnectPipeline();
  baselineImage->DisconnectPipeline();

  ImageType::SizeType baselineSize = baselineImage->GetLargestPossibleRegion().GetSize();
  ImageType::SizeType testSize     = testImage    ->GetLargestPossibleRegion().GetSize();

  if (orientationInsensitive) {
    const unsigned int OrientImageDimension = 3;
    typedef itk::Image<double, OrientImageDimension>                     OrienterImageType;
    typedef itk::ExtractImageFilter<ImageType, OrienterImageType>        ExtractorType;
    typedef itk::CastImageFilter<OrienterImageType, ImageType>           UpCasterType;
    typedef itk::OrientImageFilter<OrienterImageType, OrienterImageType> OrienterType;

    ExtractorType::Pointer extractor = ExtractorType::New();
    OrienterType ::Pointer orienter  = OrienterType ::New();
    UpCasterType ::Pointer caster    = UpCasterType ::New();

    ImageType::SizeType   extract_size;
    ImageType::IndexType  extract_index;
    ImageType::RegionType extract_region;
    extract_index.Fill(0);
    extract_size .Fill(0);

    for (unsigned int i = 0; i < ITK_TEST_DIMENSION_MAX; i++) {
        if (baselineSize[i] > 1) extract_size[i] = baselineSize[i];
    }

    extract_region.SetIndex(extract_index);
    extract_region.SetSize (extract_size);
    extractor->SetExtractionRegion(extract_region);

    orienter->UseImageDirectionOn();
    orienter->SetDesiredCoordinateOrientation(itk::SpatialOrientation::ITK_COORDINATE_ORIENTATION_RPI);


    extractor->SetInput(baselineImage);
    orienter ->SetInput(extractor->GetOutput());
    caster   ->SetInput(orienter ->GetOutput());

    try
      {
      caster->Update();
      }
    catch (itk::ExceptionObject& e)
      {
      std::cerr << "Failed to change orientation of baseline image to RPI : " << e << std::endl;
      return 1000;
      }

    baselineImage = caster->GetOutput();
    baselineSize = baselineImage->GetLargestPossibleRegion().GetSize();
    baselineImage->DisconnectPipeline();


    extractor->SetInput(testImage);
    orienter ->SetInput(extractor->GetOutput());
    caster   ->SetInput(orienter ->GetOutput());

    try
      {
      caster->Update();
      }
    catch (itk::ExceptionObject& e)
      {
      std::cerr << "Failed to change orientation of test image to RPI : " << e << std::endl;
      return 1000;
      }

    testImage = caster->GetOutput();
    testSize  = testImage->GetLargestPossibleRegion().GetSize();
    testImage->DisconnectPipeline();
  }

  // The sizes of the baseline and test image must match
  if (baselineSize != testSize)
    {
    std::cerr << "The size of the Baseline image and Test image do not match!" << std::endl;
    std::cerr << "Baseline image: " << baselineImageFilename
              << " has size " << baselineSize << std::endl;
    std::cerr << "Test image:     " << testImageFilename
              << " has size " << testSize << std::endl;
    return 1;
    }

  // Now compare the two images
#if defined(ITK_VERSION_MAJOR) && ITK_VERSION_MAJOR < 4
    typedef itk::DifferenceImageFilter<ImageType,ImageType> DiffType;
#else
    typedef itk::Testing::ComparisonImageFilter<ImageType,ImageType> DiffType;
#endif
    DiffType::Pointer diff = DiffType::New();
    diff->SetValidInput(baselineImage);
    diff->SetTestInput(testImage);
    
    diff->SetDifferenceThreshold( intensityTolerance );
    diff->SetToleranceRadius( radiusTolerance );

    diff->UpdateLargestPossibleRegion();

    bool differenceFailed = false;
  
    double averageIntensityDifference = diff->GetTotalDifference();

    unsigned long numberOfPixelsWithDifferences = diff->GetNumberOfPixelsWithDifferences();

    //The measurement errors should be reported for both success and errors
    //to facilitate setting tight tolerances of tests.
    if (reportErrors) {
        std::cout << "<DartMeasurement name=\"ImageError\" type=\"numeric/double\">";
        std::cout << numberOfPixelsWithDifferences;
        std::cout <<  "</DartMeasurement>" << std::endl;
    }

    if( averageIntensityDifference > 0.0 ) {
        if( numberOfPixelsWithDifferences > numberOfPixelsTolerance ) {
            differenceFailed = true;
        } else {
            differenceFailed = false;
        }
    } else {
        differenceFailed = false; 
    }

    if (differenceFailed && reportErrors) {
        typedef itk::RescaleIntensityImageFilter<ImageType,OutputType>    RescaleType;
        typedef itk::ExtractImageFilter<OutputType,DiffOutputType>        ExtractType;
        typedef itk::ImageFileWriter<DiffOutputType>                      WriterType;
        typedef itk::ImageRegion<ITK_TEST_DIMENSION_MAX>                  RegionType;

        OutputType::IndexType index; index.Fill(0);
        OutputType::SizeType size; size.Fill(0);

        RescaleType::Pointer rescale = RescaleType::New();

        rescale->SetOutputMinimum(itk::NumericTraits<unsigned char>::NonpositiveMin());
        rescale->SetOutputMaximum(itk::NumericTraits<unsigned char>::max());
        rescale->SetInput(diff->GetOutput());
        rescale->UpdateLargestPossibleRegion();

        //Note: This modification has been applied to the ImageCompareCommand
        //      implementation of the ITK 3.18 vs. ITK 4.0
        //
        //Get the center slice of the image,  In 3D, the first slice
        //is often a black slice with little debugging information.
        size = rescale->GetOutput()->GetLargestPossibleRegion().GetSize();
        for (unsigned int i = 2; i < ITK_TEST_DIMENSION_MAX; i++) {
            index[i] = size[i] / 2; //NOTE: Integer Divide used to get approximately
                                    // the center slice
            size[i] = 0;
        }

        RegionType region;
        region.SetIndex(index);
        region.SetSize(size);

        ExtractType::Pointer extract = ExtractType::New();

        extract->SetInput(rescale->GetOutput());
        extract->SetExtractionRegion(region);

        WriterType::Pointer writer = WriterType::New();
        writer->SetInput(extract->GetOutput());

        itksys_ios::ostringstream diffName;
        diffName << testImageFilename << ".diff.png";
        try {
            rescale->SetInput(diff->GetOutput());
            rescale->Update();
        } catch(const std::exception& e) {
          std::cerr << "Error during rescale of " << diffName.str() << std::endl;
          std::cerr << e.what() << "\n";
          }
        catch (...)
          {
          std::cerr << "Error during rescale of " << diffName.str() << std::endl;
          }
        writer->SetFileName(diffName.str().c_str());
        try
          {
          writer->Update();
          }
        catch(const std::exception& e)
          {
          std::cerr << "Error during write of " << diffName.str() << std::endl;
          std::cerr << e.what() << "\n";
          }
        catch (...)
      {
      std::cerr << "Error during write of " << diffName.str() << std::endl;
      }

    std::cout << "<DartMeasurementFile name=\"DifferenceImage\" type=\"image/png\">";
    std::cout << diffName.str();
    std::cout << "</DartMeasurementFile>" << std::endl;

    itksys_ios::ostringstream baseName;
    baseName << testImageFilename << ".base.png";
    try
      {
      rescale->SetInput(baselineImage);
      rescale->Update();
      }
    catch(const std::exception& e)
      {
      std::cerr << "Error during rescale of " << baseName.str() << std::endl;
      std::cerr << e.what() << "\n";
      }
    catch (...)
      {
      std::cerr << "Error during rescale of " << baseName.str() << std::endl;
      }
    try
      {
      writer->SetFileName(baseName.str().c_str());
      writer->Update();
      }
    catch(const std::exception& e)
      {
      std::cerr << "Error during write of " << baseName.str() << std::endl;
      std::cerr << e.what() << "\n";
      }
    catch (...)
      {
      std::cerr << "Error during write of " << baseName.str() << std::endl;
      }

    std::cout << "<DartMeasurementFile name=\"BaselineImage\" type=\"image/png\">";
    std::cout << baseName.str();
    std::cout << "</DartMeasurementFile>" << std::endl;

    itksys_ios::ostringstream testName;
    testName << testImageFilename << ".test.png";
    try
      {
      rescale->SetInput(testImage);
      rescale->Update();
      }
    catch(const std::exception& e)
      {
      std::cerr << "Error during rescale of " << testName.str() << std::endl;
      std::cerr << e.what() << "\n";
      }
    catch (...)
      {
      std::cerr << "Error during rescale of " << testName.str() << std::endl;
      }
    try
      {
      writer->SetFileName(testName.str().c_str());
      writer->Update();
      }
    catch(const std::exception& e)
      {
      std::cerr << "Error during write of " << testName.str() << std::endl;
      std::cerr << e.what() << "\n";
      }
    catch (...)
      {
      std::cerr << "Error during write of " << testName.str() << std::endl;
      }

    std::cout << "<DartMeasurementFile name=\"TestImage\" type=\"image/png\">";
    std::cout << testName.str();
    std::cout << "</DartMeasurementFile>" << std::endl;

    }
  return differenceFailed;
}


#endif // _BASIS_TESTDRIVER_ITK_HXX

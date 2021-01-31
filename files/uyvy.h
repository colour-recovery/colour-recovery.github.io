#ifndef UYVY_H
#define UYVY_H

//
// uyvy.h
//
// Defines types to support the UYVY pixel format within the Adobe Generic Image Library (GIL).
// Also provides conversions from UYVY pixels to 8 bit grey scale and 24 bit RGB.
//
// The GIL homepage is at http://opensource.adobe.com/gil/index.html
//
// This code is written for the Colour Recovery Working Group 
// See http://colour-recovery.wikispaces.com/ for details.
//
// It is licenced under a Creative Commons Attribution Share-Alike 2.5 License.
// See http://creativecommons.org/licenses/by-sa/2.5/ for details.
//
// Author: Andrew Browne 2 April 2007 
//

//
// My understanding of UYVY:-
// UYVY is a packed YUV format. Y denotes the luminance value, which can also be considered as a
// sum of weighted values of R(ed) G(reen) and B(lue), and U and V are chrominance values based on
// B-Y and R-Y respectively. In UYVY the Y, U and V values are stored in 8 bits each. The Y value
// is sampled at every pixel in the original image, but U and V are only sampled at every second
// pixel. (This is known as chroma subsampling.)
// So the byte values of a UYVY image are: U0 Y0 V0 Y1 U2 Y2 V2 Y3 U4 Y4 V4 Y5 etc.
// 
// For Colour Recovery work the source frames will obviously be monochrome so only the Y values
// will be of interest there. We will model this simply in GIL by treating a UYVY image having two
// channels - a C (chrominance) channel and a Y (luminance) channel. Each channel will be 8 bits
// so we treat a UYVY image as an interleaved image comprised of 16 bit pixels. This makes access
// to the image pixels within GIL simple and efficient.
//
// As one aim of Colour Recovery is to assign colour values to the pixels, we will have to be
// mindful when doing this as to whether a pixel's C channel should hold a U value or a V value,
// which will depend on whether the pixel's 0-based index within the image is even or odd 
// respectively.
// 
// We may want to convert our images to grey scale or RGB to allow us to use GIL's I/O extensions
// to save them in other formats such as JPEG or PNG, so we will provide colour converters for
// this. Conversion to grey scale should be straightforward as it only involves the Y values, but
// conversion to RGB will have to take account of the chroma subsampling.

#include <boost/gil/gil_all.hpp>
#include <algorithm>

// Define our types etc within the GIL namespace. (We ought to be able to use our own namespace
// but this leads to compiler errors - on Microsoft Visual C++ 2005 anyway)
namespace boost { namespace gil {  

   // Note: GIL naming conventions are used throughout

   // C (chrominance)
   struct c_t {};

   // Y (luminance)
   struct y_t {};

   // cy "colour space"
   typedef mpl::vector2<c_t, y_t> cy_t;

   // cy pixel layout
   typedef layout<cy_t> cy_layout_t;

   // define typdefs for pixels, iterators, locators, views, images etc 
   GIL_DEFINE_BASE_TYPEDEFS(8, cy)

   // Some brief examples of the uses of these types follow
   //
   // if p is a pointer to raw uyvy data for a frame image whose size is specified by height and
   // width, we can create a view on that image:-  
   //
   // cy8_view_t view(interleaved_view(width, height, reinterpret_cast<cy8_ptr_t>(p), width * 2));
   //
   // (Creating the view does not make a copy of the pixels)
   //
   // The view provides STL iterators so, for example we can use STL algorithms
   //
   // eg search for a particular sequence of pixel values in the view:-
   //
   // cy8_view_t::iterator i = search(view.begin(), view.end(), sequence.begin(), sequence.end());
   //
   // Row, column and step iterators and 2D locators are also provided
   //
   // eg do something with values of all pixels in first pixel column of view:-
   //
   // for_each(view.col_begin(0), view.col_end(0), do_something()); 
   //
   // The luminance and chrominance values of pixels can be queried and set:-
   //
   // bits8 luminance = get_color(*i, y_t()); get_color(*i, c_t()) = some_value;
   // Note: Microsoft Visual C++ 2005 does not like the alternative form - get_color<y_t>(*i) 


   // Colour conversions
   // Note: The formulae used here are based on the assumptions that the luminance and colour
   // difference values have had scaling and offsets applied so that Y has values between 16 and
   // 235 and U and V have values between 16 and 240. If these assumptions are incorrect then the
   // formulae will have to be changed.
   // The formulae are based on those at http://msdn2.microsoft.com/en-us/library/ms893078.aspx


   namespace detail {
      inline bits8 clip(long x) {return static_cast<bits8>(std::min(255L, std::max(0L, x)));}
   }

   // colour conversion to 8 bit grey scale

   struct cy8_to_gray8_converter {
      void operator()(cy8c_ref_t src, gray8_ref_t dst) const
      {
         get_color(dst, gray_color_t()) =
         detail::clip((298 * (get_color(src, y_t()) - 16)) >> 8);
      }
   };

   // For example we can output a UYVY view in grey scale PNG format as follows:-
   // png_write_view("out.png", color_converted_view<gray8_pixel_t>(view, cy8_to_gray8_converter());
   
   // colour conversion to 24 bit RGB

   // For RGB conversion we have to take account of the chroma subsampling. Pixels whose 0-based
   // index within the image hold a U value in their C channel and those whose index is odd hold
   // a V value. We keep track of this by passing an iterator or pointer to a pixel with an even
   // index to the constructor of our colour converter class. The conversion routine will use the
   // address of the even index pixel to determine whether or not the pixel currently being 
   // converted has an even index.

   class cy8_to_rgb8_converter {
   private:
      const cy8c_ptr_t even_pixel_ptr;

   public:
      template <typename Iterator>
      explicit cy8_to_rgb8_converter(Iterator even_pixel_itr) : even_pixel_ptr(&*even_pixel_itr)
      {}

      void operator()(cy8c_ref_t src, rgb8_ref_t dst) const
      {
         const long c = 298 * (get_color(src, y_t()) - 16); // 298 * (Y - 16)
         int d;
         int e;
         cy8c_ptr_t src_ptr = &src;

         if ((src_ptr - even_pixel_ptr) % 2 == 0) // even pixel
         {
            d = get_color(src, c_t()) - 128;                // U - 128
            e = get_color(*(src_ptr + 1), c_t()) - 128;     // V - 128
         }
         else // odd pixel
         {
            d = get_color(*(src_ptr - 1), c_t()) - 128;     // U - 128
            e = get_color(src, c_t()) - 128;                // V - 128
         }

         get_color(dst, red_t())   = detail::clip((c           + 409 * e + 128) >> 8);
         get_color(dst, green_t()) = detail::clip((c - 100 * d - 208 * e + 128) >> 8);
         get_color(dst, blue_t())  = detail::clip((c + 516 * d           + 128) >> 8);
      }
   };

   // For example we can output a UYVY view in RGB JPEG format as follows:-
   // jpeg_write_view("out.jpg", color_converted_view<rgb8_pixel_t>(view, cy8_to_rgb8_converter(view.begin())));
} }  

#endif // UYVY_H
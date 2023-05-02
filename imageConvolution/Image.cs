namespace Blatt4 {
    
    public class ImageCorruptException : Exception {
        public ImageCorruptException(string message)
            : base(message) {
        }
    }
    public class KernelNotOddException : Exception {
        public KernelNotOddException(string message)
            : base(message) {
        }
    }
    
    public class Image {

        private int[,]? _scanLines; // 2D-array which contains the pixel values
        private readonly string MAGIC_NUM = "P2";   // constant field 
        private readonly string COMMENT = "#";      // constant field 
        
        // getter, setter for the 2D-Array 
        public int[,]? ScanLines {
            get => _scanLines;
            set => _scanLines = value ?? throw new ArgumentNullException(nameof(value));
        }
        
        public int Width { get; set; }

        public int Height { get; set; }

        /**
         * Reads the pixel values for a given File and puts it in the 2D-Array
         * -> read all lines of the file
         * -> trim all lines
         * -> remove the comments from the list
         * -> check if the image file is valid (magic number)
         * -> extract width and height of the image
         */
        public void ReadFromFile(string filename) {
            string[] content;
            try { 
                content = File.ReadAllLines(filename); // read image file
            } catch (FileNotFoundException e) {
                Console.WriteLine(e.Message);
                return;
            }
            List<string> listContent = content.ToList();
            // trim the items
            foreach (string c in listContent) 
                c.Trim();
            // check for magic number
            if (!listContent[0].Equals(MAGIC_NUM)) 
                throw new ImageCorruptException("Image File corrupted!");
            // remove comment fields
            listContent.RemoveAll(item => item.Contains(COMMENT));
            // get the height and width of the image
            Width = int.Parse(listContent[1].Split()[0]);
            Height = int.Parse(listContent[1].Split()[1]);
            // pixels list contains all pixel values in the file as a 
            // 1D-Array field.
            List<int> pixels = new List<int>();
            for (int i = 3; i < listContent.Count; i++) 
                pixels.Add(int.Parse(listContent[i]));
            // set the ScanLine dimensions
            ScanLines = new int[Height, Width]; 
            // Convert the Pixels Array to a 2D Array 
            ConvertTo2D(pixels.ToArray());
        }
        
        /**
         * This method converts an 1D-array to an
         * 2D-array with a split condition for a
         * new row (width)
         * 
         * example:
         * input     1d: 1 2 3 4 5 6
         * 
         * result:   2d: 1 2 3
         *               4 5 6 
         */
        private void ConvertTo2D(int[] pixels) {
            int count = 0;
            for (int i = 0; i < Height; i++) {
                for (int j = 0; j < Width; j++)
                    ScanLines![i, j] = pixels[j + count];
                count += Width;
            }
        }

        /**
         * took the 2D-Array and write it to an "pgm" image file
         * @param filename - path/name of the file
         */
        public async void WriteToFile(string filename) {
            // create filestream object
            using StreamWriter writer = new StreamWriter(filename, false);
            // info of the image which not contains pixel values (magic num)
            string[] imageInfo = {
                MAGIC_NUM, 
                COMMENT + " created " + DateTime.Now.ToString("hh:mm:ss"),
                Width + " " + Height,
                "255"
            };
            // write the image info to the file
            foreach (string line in imageInfo) {
                await writer.WriteLineAsync(line);
            }
            // write the pixel values of the 2D-Array 
            for (int i = 0; i < Height; i++) {
                for (int j = 0; j < Width; j++) { 
                    writer.Write(ScanLines![i, j] + " ");
                }
                writer.Write("\n");
            }
            writer.Close();
        }

        /**
         * Takes the Image and take a blur filter over it.
         * @param kernel - filter
         * @param borderBehavior - behavior of the filter
         * @return blurred image
         */
        public Image Convolve(float[,] kernel, BorderBehavior borderBehavior) {
            Image resultImage = new Image();    // final image 
            int[,] image = ScanLines!;          // temp scanlines
            // kernel dimension not odd --> throw exception
            if (kernel.Length % 2 == 0)
                throw new KernelNotOddException("odd number expected for kernel!");
            // Generate new Image 
            for (int i = 0; i < Width; i++) {  
                for (int j = 0; j < Height; j++) { 
                    // override the current image pixel value with the result of the method
                    image[j, i] = GetFilteredPixel(i, j, kernel, borderBehavior);
                }
            }
            // setting up the result image 
            resultImage.Width = Width;
            resultImage.Height = Height;
            // set the pixel values of the blurred temp values
            resultImage.ScanLines = image;
            // return the final image
            return resultImage;
        }
        
        /**
         * Returns a new Value for the given Pixels with help of
         * the kernel and behavior
         * Result --> all manipulated pixels creates a blur effect together
         * @param i - x value of the image position
         * @param j - y value of the image position
         * @param kernel - filter 
         * @param behavior - behavior of the filter
         * @return new pixel value
         */
        public int GetFilteredPixel(int i, int j, float[,] kernel, BorderBehavior behavior) {
            float finalPixelValue = 0;  // final pixel
            int kernelHalf = kernel.GetLength(0) / 2;   // get middle of filter
            foreach (int k in Enumerable.Range(-kernelHalf, kernel.GetLength(0))) {
                foreach (int l in Enumerable.Range(-kernelHalf, kernel.GetLength(0))) {
                    // calculate the new pixel value by adding 
                    float kernelFactor = (kernel[k + kernelHalf, l + kernelHalf]);
                    float currentPixel = behavior.GetPixelValue(i + k, j + l, this);
                    finalPixelValue += currentPixel * kernelFactor;
                }
            }
            // return the final pixel value as an int
            return (int)finalPixelValue;
        }
    }
}

namespace Blatt4 {
    public class KernelFactory {
        
        /**
         * creates a (N x N) matrix with the value = 1/elements
         * example look:
         *     [0,0,0]
         *     [0,1,0]   ->  2D-Array
         *     [0,0,0]
         * 
         * @param size - size for the (N x N) matrix
         * @return filter
         */
        public static float[,] CreateBoxFilter(int size) {
            float[,] filter = new float[size,size];
            int countOfElements = size * size; // matrix dimension^2
            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    // put in the value 1/elements
                    filter[i, j] = 1.0f / countOfElements;
                }
            }
            // return the filter
            return filter;
        }

        /**
         * returns a predefined horizontal filter
         * @return horizontal filter
         */
        public static float[,] CreateHorizontalPrewitt() {
            return new[,] {
                {-1f, 0f, 1f},
                {-1f, 0f, 1f},
                {-1f, 0f, 1f}
            };
        }
        
        /**
         * returns a predefined vertical filter
         * @return vertical filter
         */
        public static float[,] CreateVerticalPrewitt() {
            return new[,] {
                {-1f, -1f, -1f},
                { 0f,  0f,  0f},
                { 1f,  1f,  1f}
            };
        }
    }
}

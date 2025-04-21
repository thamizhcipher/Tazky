module.exports = {
  transform: {
    '^.+\\.[jt]sx?$': 'babel-jest',
  },
  testEnvironment: 'jsdom',
  moduleFileExtensions: ['js', 'jsx'],
  transformIgnorePatterns: [
    '/node_modules/(?!(axios)/)', 
  ],
  moduleNameMapper: {
    '^axios$': 'axios/dist/node/axios.cjs',
  },
};

// rollup.config.js
import typescript from '@rollup/plugin-typescript'

export default {
	input: './src/shatter.ts',
  plugins:[
		typescript(/*{ plugin options }*/)
	],
  output: {
    dir: './dist'
  }
}

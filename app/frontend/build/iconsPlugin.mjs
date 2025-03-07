// Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

import { dirname, basename } from 'node:path'
import { optimize } from 'svgo'
import SVGCompiler from 'svg-baker'
import { readFileSync } from 'node:fs'

/**
 * @param {string} filepath
 * @returns {string}
 */
const optimizeSvg = (filepath) => {
  // eslint-disable-next-line security/detect-non-literal-fs-filename
  const content = readFileSync(filepath, 'utf-8')
  const result = optimize(content, {
    plugins: [{ name: 'preset-default' }],
  })
  return result.data || content
}

export default () => ({
  name: 'zammad-plugin-svgo',
  enforce: 'pre',
  /**
   * @param {string} code
   * @param {string} id
   * @returns {{code: string}}
   */
  async transform(code, id) {
    if (id.endsWith('.svg?symbol')) {
      const filepath = id.replace(/\?.*$/, '')
      const svgContent = optimizeSvg(filepath)
      const compiler = new SVGCompiler()
      const dir = basename(dirname(filepath))
      const name = basename(filepath).split('.')[0]
      const symbol = await compiler.addSymbol({
        id: `icon-${dir}-${name}`,
        content: svgContent,
        path: filepath,
      })
      return {
        code: `export default \`${symbol.render()}\``,
      }
    }
  },
})

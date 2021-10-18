import { productName, productSlug } from 'data/metadata'
import DocsPage from '@hashicorp/react-docs-page'
import {
  generateStaticPaths,
  generateStaticProps,
} from '@hashicorp/react-docs-page/server'

const NAV_DATA_FILE = 'data/intro-nav-data.json'
const CONTENT_DIR = 'content/intro'
const basePath = 'intro'

export default function DocsLayout(props) {
  return (
    <DocsPage
      product={{ name: productName, slug: productSlug }}
      baseRoute={basePath}
      staticProps={props}
      showVersionSelect={true}
    />
  )
}

export async function getStaticPaths() {
  const paths = await generateStaticPaths({
    navDataFile: NAV_DATA_FILE,
    localContentDir: CONTENT_DIR,
    // new ----
    product: { name: productName, slug: productSlug },
    basePath,
  })

  return {
    fallback: 'blocking',
    paths: paths,
  }
}

export async function getStaticProps({ params }) {
  return {
    props: await generateStaticProps({
      navDataFile: NAV_DATA_FILE,
      localContentDir: CONTENT_DIR,
      product: { name: productName, slug: productSlug },
      params,
    }),
  }
}

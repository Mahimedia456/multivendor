import { BecomeSeller } from '@components/become-seller';
import { getLayout } from '@components/layout/layout';
import { getStaticProps } from '@data/become-seller';
import { NextPageWithLayout } from '@type/index';
import { InferGetStaticPropsType } from 'next';
export { getStaticProps };
const BecomeSellerPage: NextPageWithLayout<
  InferGetStaticPropsType<typeof getStaticProps>
> = ({ data }) => {
  return (
    <div className="bg-[#F9FAFB]">
      <BecomeSeller data={data} />
    </div>
  );
};

BecomeSellerPage.getLayout = getLayout;

export default BecomeSellerPage;

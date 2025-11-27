import svgPaths from "./svg-m8f0gc2rpd";
import img8Dbd582D57D4485E8E76671287936726 from "figma:asset/09b57bf3ee6c8ff3a9cfd9958a78ffc2cb454437.png";
import imgArtist21 from "figma:asset/4816b29d2caebc6a6bd478c7c78d68fe9b858b82.png";
import imgLeftArrowBackButtonVectorIconInModernDesignStyleForWebSiteAndMobileApp2Ap88Fm1 from "figma:asset/e5b2d02426dff02ff323daa74a9b12f7fea3649b.png";
import { img8Dbd582D57D4485E8E76671287936725, imgEllispse4 } from "./svg-1eaqo";
import { useState, useRef } from "react";

function Bar() {
  return (
    <div className="absolute contents left-[calc(33.33%-2px)] top-[861px]" data-name="Bar">
      <div className="absolute bg-black h-[5.442px] left-[calc(33.33%-2px)] rounded-[34px] top-[861px] w-[145.848px]" data-name="Bar" />
    </div>
  );
}

function Bubbles() {
  return (
    <div className="absolute h-[620.085px] left-[calc(8.33%-8.43px)] top-[-297.58px] w-[566.388px]" data-name="Bubbles">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 567 621">
        <g id="Bubbles">
          <path d={svgPaths.p2d8ce940} fill="var(--fill-0, #FFD700)" id="bubble 02" />
          <path d={svgPaths.p2d346300} fill="var(--fill-0, black)" id="bubble 01" />
        </g>
      </svg>
    </div>
  );
}

function Image() {
  return (
    <div className="absolute contents left-[calc(33.33%+12px)] top-[211px]" data-name="image">
      <div className="absolute inset-[24.14%_36.52%_63.36%_36.32%]" data-name="8C7948DA-DE0D-4C75-A489-906685B1197B">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
          <g id="8C7948DA-DE0D-4C75-A489-906685B1197B"></g>
        </svg>
      </div>
      <div className="absolute inset-[16.57%_36.52%_55.79%_36.32%] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[0px_66.174px] mask-size-[109.2px_109.2px]" data-name="8DBD582D-57D4-485E-8E76-671287936725" style={{ maskImage: `url('${img8Dbd582D57D4485E8E76671287936725}')` }}>
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <img alt="" className="absolute left-0 max-w-none size-full top-0" src={img8Dbd582D57D4485E8E76671287936726} />
        </div>
      </div>
      <div className="absolute left-[calc(33.33%+3.6px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[8.4px_9.6px] mask-size-[109.2px_109.2px] size-[127.2px] top-[201.4px]" data-name="artist-2 1" style={{ maskImage: `url('${img8Dbd582D57D4485E8E76671287936725}')` }}>
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <img alt="" className="absolute h-full left-[-7.64%] max-w-none top-[8.04%] w-[114.14%]" src={imgArtist21} />
        </div>
      </div>
    </div>
  );
}

function Group() {
  return (
    <div className="absolute contents left-[calc(33.33%+4px)] top-[203px]">
      <div className="absolute inset-[203px_calc(33.33%+4px)_545px_calc(33.33%+4px)]" data-name="ellipse">
        <div className="absolute inset-[-3.97%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 136 136">
            <g filter="url(#filter0_d_1_145)" id="ellipse">
              <path d={svgPaths.p20560800} fill="var(--fill-0, #8F7902)" />
            </g>
            <defs>
              <filter colorInterpolationFilters="sRGB" filterUnits="userSpaceOnUse" height="136" id="filter0_d_1_145" width="136" x="0" y="0">
                <feFlood floodOpacity="0" result="BackgroundImageFix" />
                <feColorMatrix in="SourceAlpha" result="hardAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" />
                <feOffset />
                <feGaussianBlur stdDeviation="2.5" />
                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.160784 0" />
                <feBlend in2="BackgroundImageFix" mode="normal" result="effect1_dropShadow_1_145" />
                <feBlend in="SourceGraphic" in2="effect1_dropShadow_1_145" mode="normal" result="shape" />
              </filter>
            </defs>
          </svg>
        </div>
      </div>
      <Image />
    </div>
  );
}

function Ellispse() {
  return (
    <div className="absolute left-[calc(25%-13.5px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[68px_243px] mask-size-[96px_95px] size-[17px] top-0" data-name="ellispse 4" style={{ maskImage: `url('${imgEllispse4}')` }}>
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17 17">
        <g id="ellispse 4">
          <path d={svgPaths.pce22900} fill="var(--fill-0, #E5EBFC)" id="ellispse 01" />
        </g>
      </svg>
    </div>
  );
}

function Button() {
  return (
    <div className="absolute h-[53px] left-[calc(8.33%+1.5px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[120px_-408px] mask-size-[96px_95px] overflow-clip top-[540px] w-[332px]" data-name="Button" style={{ maskImage: `url('${imgEllispse4}')` }}>
      <div className="absolute bg-black inset-0 rounded-[16px]" />
      <p className="absolute font-['Nunito_Sans:Bold',sans-serif] font-bold leading-[31px] left-[21.89%] right-[21.89%] text-[#f3f3f3] text-[22px] text-center top-[calc(50%-15.5px)]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        Confirm
      </p>
    </div>
  );
}

function Group1() {
  return (
    <div className="absolute contents left-[calc(25%+13.5px)] top-[506px]">
      <div className="absolute bg-[#fff1c6] border border-[#8f7902] border-solid left-[calc(25%+13.5px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[41px_-263px] mask-size-[96px_95px] rounded-[7px] size-[37px] top-[506px]" style={{ maskImage: `url('${imgEllispse4}')` }} />
      <div className="absolute bg-[#fff1c6] border border-[#8f7902] border-solid left-[calc(41.67%-6.5px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[-6px_-263px] mask-size-[96px_95px] rounded-[7px] size-[37px] top-[506px]" style={{ maskImage: `url('${imgEllispse4}')` }} />
      <div className="absolute bg-[#fff1c6] border border-[#8f7902] border-solid left-[calc(50%+7px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[-53px_-263px] mask-size-[96px_95px] rounded-[7px] size-[37px] top-[506px]" style={{ maskImage: `url('${imgEllispse4}')` }} />
      <div className="absolute bg-[#fff1c6] border border-[#8f7902] border-solid left-[calc(58.33%+23.5px)] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[-103px_-263px] mask-size-[96px_95px] rounded-[7px] size-[37px] top-[506px]" style={{ maskImage: `url('${imgEllispse4}')` }} />
    </div>
  );
}

function Border() {
  return (
    <div className="absolute bottom-0 left-0 right-[2.33px] top-0" data-name="Border">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 22 12">
        <g clipPath="url(#clip0_1_112)" id="Border">
          <g id="Shape"></g>
          <mask height="12" id="mask0_1_112" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="22" x="0" y="0">
            <path d={svgPaths.p260541f0} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_112)">
            <path d={svgPaths.p2ca600} id="Fill" stroke="var(--stroke-0, white)" strokeOpacity="0.34902" strokeWidth="2" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_112">
            <rect fill="white" height="11.3333" width="22" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Cap() {
  return (
    <div className="absolute h-[4px] right-0 top-1/2 translate-y-[-50%] w-[1.328px]" data-name="Cap">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 2 4">
        <g id="Cap">
          <g id="Shape"></g>
          <mask height="4" id="mask0_1_107" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="2" x="0" y="0">
            <path d={svgPaths.p2b99ae00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_107)">
            <path d="M-5 -5H6.328V9H-5V-5Z" fill="var(--fill-0, white)" fillOpacity="0.4" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Capacity() {
  return (
    <div className="absolute h-[7.333px] left-[2px] top-1/2 translate-y-[-50%] w-[18px]" data-name="Capacity">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 18 8">
        <g id="Capacity">
          <g id="Shape"></g>
          <mask height="8" id="mask0_1_102" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="18" x="0" y="0">
            <path d={svgPaths.p8246f00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_102)">
            <path d="M-5 -5H23V12.3333H-5V-5Z" fill="var(--fill-0, white)" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Battery() {
  return (
    <div className="absolute h-[11.333px] overflow-clip right-[27.67px] top-[calc(50%+1px)] translate-y-[-50%] w-[24.328px]" data-name="Battery">
      <Border />
      <Cap />
      <Capacity />
    </div>
  );
}

function Wifi() {
  return (
    <div className="absolute h-[10.966px] overflow-clip right-[54.03px] top-[calc(50%+0.81px)] translate-y-[-50%] w-[15.272px]" data-name="Wifi">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 11">
        <g clipPath="url(#clip0_1_91)" id="Wifi">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_91" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="16" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35f5d700} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_91)">
            <path d={svgPaths.p592eaf0} fill="var(--fill-0, white)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_91">
            <rect fill="white" height="10.9656" width="15.2724" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function CellularConnection() {
  return (
    <div className="absolute h-[10.667px] left-[calc(50%+104.17px)] overflow-clip top-[calc(50%+1px)] translate-x-[-50%] translate-y-[-50%] w-[17px]" data-name="Cellular Connection">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17 11">
        <g clipPath="url(#clip0_1_125)" id="Cellular Connection">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_125" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="17" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35ce9400} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_125)">
            <path d="M-8 -5H19V15.6667H-8V-5Z" fill="var(--fill-0, white)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_125">
            <rect fill="white" height="10.6667" width="17" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function BarsTimeBlack() {
  return (
    <div className="absolute inset-[29.55%_80%_29.55%_5.6%] overflow-clip" data-name="Bars/_/Time Black">
      <div className="absolute bottom-[1.64px] left-0 right-[-0.11px] top-0" data-name="Background">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
          <g id="Background"></g>
        </svg>
      </div>
      <p className="absolute font-['Nunito_Sans:SemiBold',sans-serif] font-semibold h-[16px] leading-[normal] left-0 right-0 text-[14px] text-black text-center top-[calc(50%-6.82px)] tracking-[0.0039px]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        9:41
      </p>
    </div>
  );
}

function BarsStatusBarLightStatusBar() {
  return (
    <div className="absolute h-[48px] left-0 mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[155px_243px] mask-size-[96px_95px] overflow-clip top-0 w-[402px]" data-name="Bars/Status Bar/Light Status Bar" style={{ maskImage: `url('${imgEllispse4}')` }}>
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
        <g id="Background"></g>
      </svg>
      <Battery />
      <Wifi />
      <CellularConnection />
      <BarsTimeBlack />
    </div>
  );
}

export default function ResetPassword() {
  const [otp, setOtp] = useState(['', '', '', '']);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const handleOtpChange = (index: number, value: string) => {
    // Only allow digits
    if (value && !/^\d$/.test(value)) return;
    
    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);
    
    // Auto-focus next input
    if (value && index < 3) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  return (
    <div className="bg-white relative size-full" data-name="ResetPassword">
      <Bar />
      <Bubbles />
      <Group />
      <p className="absolute font-['Nunito_Sans:Bold',sans-serif] font-bold h-[26px] leading-[25px] left-[calc(33.33%+70.5px)] text-[16px] text-black text-center top-[467px] tracking-[1.6px] translate-x-[-50%] w-[123px]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        +94*******41
      </p>
      
      {/* OTP Input Boxes */}
      <div className="absolute flex gap-[10px] justify-center left-1/2 top-[515px] translate-x-[-50%]">
        {[0, 1, 2, 3].map((index) => (
          <input
            key={index}
            ref={(el) => (inputRefs.current[index] = el)}
            type="text"
            inputMode="numeric"
            maxLength={1}
            value={otp[index]}
            onChange={(e) => handleOtpChange(index, e.target.value)}
            onKeyDown={(e) => handleKeyDown(index, e)}
            className="bg-[#fff1c6] border border-[#8f7902] border-solid rounded-[7px] size-[37px] text-center text-[20px] font-['Nunito_Sans:Bold',sans-serif] font-bold text-black focus:outline-none focus:border-2 focus:border-[#8f7902]"
            style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}
          />
        ))}
      </div>
      
      <p className="absolute font-['Nunito_Sans:Light',sans-serif] font-light h-[60px] leading-[27px] left-[calc(16.67%+137px)] text-[19px] text-black text-center top-[394px] translate-x-[-50%] w-[306px]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        Enter 4-digits code we sent you on your phone number
      </p>
      <p className="absolute font-['Raleway:Bold',sans-serif] font-bold h-[31px] leading-[30px] left-[calc(25%+104px)] text-[#202020] text-[21px] text-center top-[358px] tracking-[-0.21px] translate-x-[-50%] w-[203px]">Password Recovery</p>
      <Ellispse />
      <Button />
      <p className="absolute font-['Nunito_Sans:Bold',sans-serif] font-bold leading-[26px] left-1/2 text-[15px] text-black text-center text-nowrap top-[623px] translate-x-[-50%] cursor-pointer" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        Cancel
      </p>
      <Group1 />
      <button className="absolute left-[16px] top-[18px] flex items-center justify-center bg-white border-2 border-black rounded-full size-[40px] cursor-pointer hover:bg-gray-50 transition-colors">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
      </button>
      <BarsStatusBarLightStatusBar />
    </div>
  );
}